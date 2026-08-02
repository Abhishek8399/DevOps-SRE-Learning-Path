---
{
  "schemaVersion": 1,
  "kind": "lesson",
  "id": "LES-0017",
  "aliases": ["V03-L02", "bash-safe-automation"],
  "curriculumIds": ["AUT-001"],
  "slug": "bash-safe-automation",
  "route": "/book/engineering/bash-safe-automation",
  "order": 2,
  "volume": "03-engineering-delivery",
  "title": "Safe Bash automation: make failure visible, bounded, and recoverable",
  "summary": "Build Bash automation from the parser outward: preserve data through quoting and record framing, propagate failure deliberately, validate state boundaries, survive interruption, retry only safe operations, coordinate concurrent runs, and prove cleanup, rollback, and real outcomes.",
  "domain": "engineering",
  "level": {
    "from": "foundation",
    "to": "advanced"
  },
  "estimatedMinutes": 480,
  "prerequisiteLessonIds": ["LES-0009", "LES-0002"],
  "prerequisiteCurriculumIds": ["SCM-001", "LNX-002"],
  "testedEnvironments": [
    {
      "platform": "Ubuntu",
      "version": "24.04 LTS",
      "support": "required",
      "notes": "The lesson targets the Ubuntu-provided Bash 5.2 family and GNU userland. The required lab runs as a normal user, installs nothing, opens no port, makes no network request, and creates only a guarded UID-scoped directory and state descriptor beneath /tmp."
    },
    {
      "platform": "Windows Subsystem for Linux (WSL 2) Ubuntu",
      "version": "24.04 LTS",
      "support": "supported",
      "notes": "The offline lab is supported. Linux permission, signal, advisory-lock, executable-bit, and path semantics are taught from inside WSL; Windows processes and NTFS-mounted paths can have different behavior, so do not generalize the lab beyond the observed filesystem and process boundary."
    },
    {
      "platform": "CI runners, containers, Kubernetes, private cloud, and public cloud",
      "version": "provider-neutral concepts",
      "support": "concept-only",
      "notes": "Production transfer covers runner images, process namespaces, controller retries, distributed idempotency, secret injection, termination grace periods, and logs, but this lesson creates no remote job, container, cluster, cloud resource, or paid service."
    }
  ],
  "targetRoles": [
    "site-reliability-engineer",
    "devops-engineer",
    "platform-engineer",
    "production-engineer",
    "cloud-infrastructure-engineer",
    "release-engineer",
    "security-engineer",
    "data-platform-engineer"
  ],
  "learningObjectives": [
    "Trace a Bash command through tokenization, parsing, expansion, redirection, execution, wait, and exit-status selection so that quoting and control-flow defects can be derived instead of memorized.",
    "Preserve arguments and records containing whitespace, wildcard characters, leading dashes, empty strings, and newlines by choosing an explicit data-framing contract and quoted arrays.",
    "Design exit statuses, standard output, standard error, pipelines, functions, subshells, and strict options as an explicit failure interface rather than treating `set -euo pipefail` as a safety guarantee.",
    "Validate command-line, environment, numeric, enum, path, ownership, symlink, and file-type boundaries before mutation while rejecting code generation, `eval`, and unsafe cleanup.",
    "Use traps, secure temporary state, signals, atomic local publication, idempotency keys, reconciliation, bounded retries, deadlines, locks, and rollback according to the state owner each mechanism can actually protect.",
    "Build repeatable Bash validation with parser checks, ShellCheck, unit-like function tests, black-box CLI tests, hostile-input fixtures, failure injection, concurrency tests, and cleanup proofs.",
    "Transfer a local script design to CI and Kubernetes by identifying changed identity, filesystem, namespace, termination, secret, retry, durable-state, and distributed-coordination boundaries.",
    "Recognize when Bash remains a good thin orchestrator and when structured data, concurrency, protocol complexity, or long-term interfaces justify moving the core to Python, Go, or another general-purpose language."
  ],
  "productionSignals": [
    "A script reports success although an earlier pipeline stage failed or a required output is incomplete.",
    "A loop skips or invents records when a pathname, tenant name, branch, or payload field contains spaces, wildcard characters, a leading dash, an empty value, or a newline.",
    "A retry duplicates a deployment, ticket, payment-like operation, notification, or configuration change because the previous attempt timed out after the side effect.",
    "Two CI jobs, cron invocations, operators, or Kubernetes replicas update the same marker, report, lock, or remote object at the same time.",
    "An EXIT trap removes the wrong path, hides the original status, leaks a temporary secret, or assumes cleanup ran after SIGKILL or host loss.",
    "A script passes locally but fails in CI because `/bin/sh` is not Bash, the working directory differs, an environment variable is absent, a tool version changes, or a read-only filesystem blocks publication.",
    "Logs expose tokens or payloads because xtrace, command arguments, environment dumps, error bodies, or signed URLs entered a central log platform.",
    "A Bash program grows into a parser, protocol client, concurrent scheduler, and durable state machine that reviewers can no longer reason about safely."
  ],
  "diagrams": [
    {
      "id": "LES-0017-DIA-001",
      "title": "Bash turns source text into an observed status through ordered boundaries",
      "direction": "left-to-right",
      "boundaries": ["source bytes", "tokens and grammar", "expansions and quote removal", "redirections and file descriptors", "command lookup and execution environment", "child or builtin execution", "wait and exit-status selection", "caller decision"],
      "evidencePoints": ["script bytes and shebang", "bash -n and parser diagnostics", "printf percent-q and argument count", "declared standard streams", "type and command -V", "process and side effects", "status and PIPESTATUS", "verified postcondition"],
      "textAlternative": "Bash reads source text, recognizes tokens and grammar, expands words, applies redirections, finds and runs commands, waits for results, chooses an exit status, and returns it to a caller that must still verify the intended outcome."
    },
    {
      "id": "LES-0017-DIA-002",
      "title": "Reliable automation separates intent, candidate state, committed state, and external effects",
      "direction": "left-to-right",
      "boundaries": ["validated CLI intent", "lock and current-state reread", "durable operation identity", "bounded attempt", "unknown or known outcome", "reconciliation", "validated local candidate", "atomic local publication", "real-operation verification"],
      "evidencePoints": ["normalized arguments", "lock result and state version", "idempotency key", "attempt and deadline", "status and response class", "remote query or receipt", "schema and count checks", "rename and prior artifact", "user-visible or delivery result"],
      "textAlternative": "Validated intent enters a serialized local critical section, receives a durable logical operation identity, makes a bounded attempt, reconciles unknown outcomes, validates candidate output, publishes local state, and finally verifies the actual operation."
    },
    {
      "id": "LES-0017-DIA-003",
      "title": "One missing quote can change data before the program sees it",
      "direction": "top-to-bottom",
      "boundaries": ["one logical value containing spaces and wildcard characters", "unquoted parameter or command substitution", "IFS word splitting", "pathname expansion", "several changed arguments", "utility option or path interpretation", "wrong side effect"],
      "evidencePoints": ["original byte sequence", "quoted versus unquoted source", "argument count", "percent-q rendering", "working-directory matches", "double-dash boundary", "filesystem diff and exit status"],
      "textAlternative": "A value intended as one argument is expanded without quotes, split into words, and treated as filename patterns before the called utility starts, so the utility receives different arguments and may act on different paths."
    },
    {
      "id": "LES-0017-DIA-004",
      "title": "Interruption and retry form a state machine, not a loop around a command",
      "direction": "cyclic",
      "boundaries": ["intent recorded", "attempt started", "definite rejection", "definite commit", "unknown outcome after timeout", "reconcile by operation identity", "retry eligible", "completed and verified", "manual decision or compensation"],
      "evidencePoints": ["manifest", "attempt number and start time", "classified permanent status", "receipt", "deadline or lost response", "authoritative state query", "budget and backoff", "postcondition", "incident record"],
      "textAlternative": "An attempt can be definitely rejected, definitely committed, or unknown; only classified transient rejection is directly retryable, while an unknown mutation must be reconciled by durable operation identity before completion, retry, or compensation."
    }
  ],
  "commands": [
    {
      "id": "LES-0017-CMD-001",
      "question": "Which Bash, operating system, identity, directory, and key utilities define this run?",
      "risk": "read-only",
      "command": "bash --version | head -n 1; cat /etc/os-release; id; pwd -P; command -V bash find stat mktemp timeout flock",
      "runFrom": "The exact Ubuntu 24.04 or WSL Ubuntu shell that will run the automation",
      "expectedBranches": [
        {
          "when": "Bash, Ubuntu 24.04, the expected non-root identity, canonical directory, and required commands are visible",
          "meaning": "The execution baseline matches the supported lesson boundary.",
          "nextEvidence": "Record script and dependency versions, then inspect syntax before mutation."
        },
        {
          "when": "The interpreter, identity, directory, or command resolution differs",
          "meaning": "A foundational runtime assumption is false.",
          "nextEvidence": "Stop; select the intended normal-user environment rather than installing, elevating, or guessing."
        }
      ],
      "proves": "Displayed runtime metadata and command resolution for this shell at this moment.",
      "doesNotProve": "Script correctness, dependency behavior, safe inputs, permission to mutate a target, or production parity."
    },
    {
      "id": "LES-0017-CMD-002",
      "question": "Does Bash parse the entire script without executing it?",
      "risk": "read-only",
      "command": "bash -n -- ./script.sh",
      "runFrom": "A reviewed local repository containing the named script; replace the example path only with the intended file",
      "expectedBranches": [
        {
          "when": "Exit status is 0 and standard error is empty",
          "meaning": "Bash found no syntax error in the parsed file under this interpreter.",
          "nextEvidence": "Run static analysis and behavioral tests; parsing success is only the first gate."
        },
        {
          "when": "Exit status is nonzero with a file and line diagnostic",
          "meaning": "The parser could not form a valid program.",
          "nextEvidence": "Fix the first parser error and rerun; later diagnostics may be consequences."
        }
      ],
      "proves": "That this Bash invocation could parse the selected file without executing its commands.",
      "doesNotProve": "Correct expansions, command availability, runtime branches, exit policy, safe side effects, portability, or semantic correctness."
    },
    {
      "id": "LES-0017-CMD-003",
      "question": "What exact arguments did expansion produce?",
      "risk": "read-only",
      "command": "bash -c 'printf \"argc=%d\\n\" \"$#\"; printf \"arg=%q\\n\" \"$@\"' _ 'quarter close.log' '--looks-like-option' '' '*'",
      "runFrom": "A scratch shell where printing synthetic values is safe; no real target path is passed",
      "expectedBranches": [
        {
          "when": "Four arguments remain and percent-q output makes spaces, empty value, leading dashes, and literal wildcard visible",
          "meaning": "The quoted call preserved each source argument boundary.",
          "nextEvidence": "Apply the same quoted-array discipline at the actual utility boundary and use `--` where supported."
        },
        {
          "when": "Count or rendering differs after editing the example",
          "meaning": "An expansion changed word boundaries or content.",
          "nextEvidence": "Inspect the call site for unquoted expansion, `eval`, or reconstruction from text."
        }
      ],
      "proves": "The argument vector received by the synthetic child after this parent shell's parsing and expansion.",
      "doesNotProve": "That percent-q is a portable storage format, that the utility interprets arguments safely, or that a real path is authorized."
    },
    {
      "id": "LES-0017-CMD-004",
      "question": "Can arbitrary pathname bytes except NUL survive discovery into a Bash array?",
      "risk": "sampled-read-only",
      "command": "readarray -d '' -t paths < <(find -- ./fixture -type f -print0); printf 'count=%d\\n' \"${#paths[@]}\"; printf 'path=%q\\n' \"${paths[@]}\"",
      "runFrom": "A synthetic, reviewed local fixture directory; the command reads but does not modify it",
      "expectedBranches": [
        {
          "when": "The count matches fixture files and each percent-q rendering is one array element",
          "meaning": "NUL-delimited discovery preserved pathname boundaries for this fixture.",
          "nextEvidence": "Pass elements as `\"${paths[@]}\"` and add `--` at downstream option boundaries."
        },
        {
          "when": "The directory is missing, permissions fail, or count differs",
          "meaning": "Discovery or fixture assumptions failed; process substitution may otherwise hide producer status if it is not checked separately.",
          "nextEvidence": "Capture the producer status through a design that makes it observable before trusting the array."
        }
      ],
      "proves": "The records Bash read into the array from the shown producer for that snapshot.",
      "doesNotProve": "That files did not change after discovery, that every producer failure is propagated through process substitution, or that each path is safe to mutate."
    },
    {
      "id": "LES-0017-CMD-005",
      "question": "Which stage of a Bash pipeline failed, and which status would the caller receive?",
      "risk": "read-only",
      "command": "bash -c 'set +e; set -o pipefail; { printf \"record\\n\"; exit 23; } | sed -n \"1p\"; pipeline_status=$? stages=(\"${PIPESTATUS[@]}\"); printf \"pipeline=%d stages=%s\\n\" \"$pipeline_status\" \"${stages[*]}\"'",
      "runFrom": "Any supported lesson shell; the child emits one synthetic line and creates no file",
      "expectedBranches": [
        {
          "when": "The emitted record appears and the captured pipeline status is 23",
          "meaning": "Output can exist even when the producer failed, and `pipefail` selected a nonzero status.",
          "nextEvidence": "Use an explicit branch to prevent partial output from being published and capture needed stage details immediately."
        },
        {
          "when": "An edited pipeline reports 0",
          "meaning": "The selected status represented a successful last stage or the failure was handled in another grammar context.",
          "nextEvidence": "Inspect pipeline options, syntactic context, and stage statuses rather than trusting visible output."
        }
      ],
      "proves": "The selected pipeline and stage statuses for a synthetic child under the shown Bash options.",
      "doesNotProve": "Atomicity, rollback, absence of partial effects, safety of all pipelines, or behavior in another shell."
    },
    {
      "id": "LES-0017-CMD-006",
      "question": "What common shell defects and portability mismatches can static analysis identify?",
      "risk": "read-only",
      "command": "shellcheck --severity=warning --shell=bash -- ./script.sh",
      "runFrom": "A repository where ShellCheck is already available; do not install it automatically",
      "expectedBranches": [
        {
          "when": "No warning is emitted and status is 0",
          "meaning": "The file passed this ShellCheck version, shell dialect, directives, and severity threshold.",
          "nextEvidence": "Run behavioral and failure tests because static analysis does not know the full application contract."
        },
        {
          "when": "A diagnostic identifies a code, line, and explanation",
          "meaning": "A reviewed rule found a likely issue or portability concern.",
          "nextEvidence": "Understand the rule, correct the mechanism, or add the narrowest justified documented directive with a test."
        }
      ],
      "proves": "The diagnostics produced by that ShellCheck version under the chosen dialect and severity.",
      "doesNotProve": "Semantic correctness, security, idempotency, safe paths, dependency availability, test coverage, or production readiness."
    },
    {
      "id": "LES-0017-CMD-007",
      "question": "Does a command complete inside an explicit time budget, and how did timeout classify it?",
      "risk": "mutating-bounded",
      "command": "timeout --signal=TERM --kill-after=2s 5s bash -c 'trap \"exit 42\" TERM; sleep 30'",
      "runFrom": "A supported lesson shell; the command starts and may signal only its synthetic child process",
      "expectedBranches": [
        {
          "when": "The wrapper returns a timeout-related nonzero status after about five seconds",
          "meaning": "The child did not complete inside the budget and received the configured signal; exact status depends on whether status preservation is requested and how the child exits.",
          "nextEvidence": "Classify the operation's outcome and reconcile any side effect before considering retry."
        },
        {
          "when": "The child exits before the deadline",
          "meaning": "The wrapper returns the child's status under the selected options.",
          "nextEvidence": "Verify the actual postcondition; completion is not the same as success."
        }
      ],
      "proves": "How the shown local wrapper bounded and classified one synthetic child invocation.",
      "doesNotProve": "That a remote mutation was not accepted, that grandchildren were all terminated, or that timeout plus retry is safe."
      ,"cleanup": "The synthetic child terminates through TERM or the configured kill-after escalation; no persistent file, socket, or service is created."
    },
    {
      "id": "LES-0017-CMD-008",
      "question": "Can this invocation acquire an advisory lock without waiting indefinitely?",
      "risk": "mutating-bounded",
      "command": "( : \"${ATLAS_PRIVATE_DIR:?export ATLAS_PRIVATE_DIR as an approved private directory}\"; case \"$ATLAS_PRIVATE_DIR\" in /*) ;; *) printf \"refusal=path-not-absolute\\n\" >&2; exit 64;; esac; [[ -d \"$ATLAS_PRIVATE_DIR\" && ! -L \"$ATLAS_PRIVATE_DIR\" ]] || { printf \"refusal=not-a-real-directory\\n\" >&2; exit 77; }; [[ \"$(stat -Lc %u -- \"$ATLAS_PRIVATE_DIR\")\" == \"$(id -u)\" && \"$(stat -Lc %a -- \"$ATLAS_PRIVATE_DIR\")\" == 700 ]] || { printf \"refusal=owner-or-mode\\n\" >&2; exit 77; }; exec 9<\"$ATLAS_PRIVATE_DIR\"; [[ ! -L \"$ATLAS_PRIVATE_DIR\" && \"$(stat -Lc %d:%i -- \"$ATLAS_PRIVATE_DIR\")\" == \"$(stat -Lc %d:%i -- /proc/self/fd/9)\" ]] || { printf \"refusal=directory-changed-during-open\\n\" >&2; exit 77; }; if flock -n 9; then printf \"lock=acquired\\n\"; else printf \"lock=contended\\n\" >&2; exit 75; fi )",
      "runFrom": "After exporting `ATLAS_PRIVATE_DIR` as an approved absolute directory already owned by the current UID, mode 0700, and not a symbolic link; the command opens and locks that directory object without creating or truncating a lock file",
      "expectedBranches": [
        {
          "when": "lock=acquired and status is 0",
          "meaning": "This cooperating process holds the advisory lock on descriptor 9 until it exits or closes that descriptor.",
          "nextEvidence": "Reread protected state after acquisition, then keep the critical section narrow."
        },
        {
          "when": "lock=contended and status is 75",
          "meaning": "Another cooperating holder owns the lock at that instant.",
          "nextEvidence": "Return a documented temporary-failure outcome or wait within a bounded policy; do not delete a lock path to steal ownership."
        }
      ],
      "proves": "The directory passed the shown owner, mode, leaf-symlink, and identity checks, and this process acquired or failed to acquire a nonblocking advisory lock on its opened directory descriptor.",
      "doesNotProve": "Who owns a contended lock, coordination across another filesystem or host, compliance by noncooperating writers, or remote exactly-once behavior.",
      "cleanup": "The lock releases when the child exits and closes descriptor 9; this command creates, truncates, and deletes no filesystem object, so the caller retains ownership of the pre-existing private directory lifecycle."
    },
    {
      "id": "LES-0017-CMD-009",
      "question": "What owner, type, mode, link count, size, and canonical path protect a candidate state file?",
      "risk": "read-only",
      "command": "stat --printf='type=%F uid=%u mode=%a links=%h size_bytes=%s path=%n\\n' -- ./candidate; readlink -e -- ./candidate",
      "runFrom": "The validated parent of a synthetic or approved candidate path",
      "expectedBranches": [
        {
          "when": "A regular file, expected UID, restrictive mode, one link, bounded size, and expected canonical path appear",
          "meaning": "Those path invariants hold for this snapshot.",
          "nextEvidence": "Validate content and recheck invariants immediately before publication or cleanup."
        },
        {
          "when": "Type, owner, mode, link count, size, or canonical location differs",
          "meaning": "The candidate crossed or violated its declared boundary.",
          "nextEvidence": "Refuse mutation and investigate; do not compensate with sudo or broad deletion."
        }
      ],
      "proves": "The displayed metadata and resolution for the selected path at observation time.",
      "doesNotProve": "Content correctness, absence of a time-of-check/time-of-use race, authorization, or safety of a parent directory."
    },
    {
      "id": "LES-0017-CMD-010",
      "question": "Does the script depend on an undeclared interactive environment?",
      "risk": "read-only",
      "command": "env -i HOME=\"$HOME\" PATH='/usr/bin:/bin' LANG=C.UTF-8 bash --noprofile --norc ./script.sh --help",
      "runFrom": "A reviewed local script whose help action is documented read-only",
      "expectedBranches": [
        {
          "when": "Help renders and status matches the CLI contract",
          "meaning": "That code path did not require undeclared startup files or other removed environment entries.",
          "nextEvidence": "Test each behavioral path with an explicit environment fixture."
        },
        {
          "when": "The script fails for a missing variable, command, locale, or path",
          "meaning": "It depends on ambient state not declared in this invocation.",
          "nextEvidence": "Decide whether to validate and require the dependency, provide a safe default, or remove it."
        }
      ],
      "proves": "Behavior of the help path under the shown reduced environment.",
      "doesNotProve": "Full hermeticity, safe HOME use, success of mutating paths, container parity, or absence of time and filesystem dependencies."
    },
    {
      "id": "LES-0017-CMD-011",
      "question": "Does the guarded offline lesson lab pass its lifecycle and refusal contract?",
      "risk": "mutating-bounded",
      "command": "bash verify.sh",
      "runFrom": "book/labs/LES-0017-bash-automation as a normal non-root user on Ubuntu 24.04",
      "expectedBranches": [
        {
          "when": "Every named verifier check passes and final state is absent",
          "meaning": "The lab lifecycle, deterministic evidence, selected refusal cases, recovery, operation verification, and cleanup passed in this environment.",
          "nextEvidence": "Complete the independent reasoning deliverable; verifier success is not mastery."
        },
        {
          "when": "A check fails or state remains",
          "meaning": "A lab invariant, dependency, fixture, or cleanup contract failed.",
          "nextEvidence": "Stop and inspect the first failure; do not use sudo or manually delete an unvalidated path."
        }
      ],
      "proves": "The verifier's declared automated checks in the observed environment.",
      "doesNotProve": "Learner understanding, production safety, every hostile input, every race, or behavior outside the modeled cases.",
      "cleanup": "The verifier invokes guarded cleanup and requires both the registered root and UID-scoped descriptor to be absent."
    }
  ],
  "labs": [
    {
      "id": "LES-0017-LAB-001",
      "title": "Guided Bash failure-boundary workbench",
      "mode": "guided",
      "environment": "Ubuntu 24.04 or WSL 2 Ubuntu 24.04, Bash and base GNU utilities, deterministic offline fixture",
      "timeMinutes": 75,
      "privilege": "Normal user only; root is refused before state mutation",
      "network": "None; the fixture creates no socket and makes no DNS, HTTP, package, container, cluster, or cloud request",
      "changes": ["One private mktemp directory directly beneath /tmp", "One UID-scoped mode-0600 state descriptor beneath /tmp", "Allowlisted text evidence, copied fixture, lock object, and verification receipt inside the registered directory"],
      "abortConditions": ["Effective UID is zero", "Ubuntu Bash or required base utilities are missing", "/tmp ownership, type, permissions, or sticky-bit contract fails", "A state descriptor or matching root fails owner, type, mode, prefix, sentinel, manifest, or allowlist validation", "Any command proposes an arbitrary path, network access, package installation, elevation, or source modification"],
      "recovery": "Use only `bash lab.sh recover` after selecting the guided case; it records a modeled correction tied to preserved evidence and does not operate a real external target.",
      "cleanupProof": "`bash lab.sh cleanup` revalidates every state boundary, removes only named allowlisted files, removes empty allowlisted directories, uses rmdir for the exact registered root, removes the exact descriptor, and then `bash lab.sh check` reports state=absent.",
      "path": "book/labs/LES-0017-bash-automation"
    },
    {
      "id": "LES-0017-LAB-002",
      "title": "Independent interrupted-idempotency transfer",
      "mode": "independent",
      "environment": "The same guarded Ubuntu 24.04 offline workbench with answer-isolated raw input and deterministic derived evidence",
      "timeMinutes": 110,
      "privilege": "Normal user only; no sudo, capability, other-user process inspection, or host-service mutation",
      "network": "None; remote effects, timeouts, locks, and retries are virtual records only",
      "changes": ["The same lesson-owned guarded temporary root and descriptor", "One independent case selection, evidence views, modeled recovery record, and operation-verification receipt"],
      "abortConditions": ["Raw-input prediction was not written before derived observations", "Fixture source or answer material was inspected", "A guard refuses state", "The proposed recovery uses blind replay, broad deletion, unbounded retry, code evaluation, or privilege elevation"],
      "recovery": "Reconcile the virtual attempt by durable operation identity, choose the least-risk modeled next state, and record it with the guarded recover action only after explaining why replay is or is not safe.",
      "cleanupProof": "The same validated cleanup plus final absent-state check applies; reviewer evidence and reasoning live outside the lab root before cleanup.",
      "path": "book/labs/LES-0017-bash-automation"
    }
  ],
  "incidents": [
    {
      "id": "LES-0017-INC-001",
      "signal": "A CI publication step is green and a report exists, but consumers find missing records; the producer logged a failure and record names contain spaces or wildcard characters.",
      "firstThought": "Treat success as an unverified claim. Follow record framing, expansion, pipeline status, candidate validation, and publication as separate boundaries before rerunning anything.",
      "safePath": "Freeze retries, preserve version and streams, reproduce with synthetic hostile records and an injected producer exit, inspect argument count and stage statuses, then reconcile intended records with committed effects before a staged validated republish.",
      "trap": "Adding strict mode and rerunning the entire batch can still split records, expose partial state, and duplicate prior effects."
    },
    {
      "id": "LES-0017-INC-002",
      "signal": "A deployment helper times out, its local marker says pending, a second runner starts, and the remote service may already have accepted the first request.",
      "firstThought": "Timeout means the observer lost a timely answer, not that the side effect definitely failed. Separate local lock ownership from remote logical operation identity.",
      "safePath": "Stop admission, acquire a scoped local lock, reread durable intent, query authoritative state by idempotency key, record definite or unknown outcome, and only then complete, compensate, or make a bounded classified retry.",
      "trap": "Deleting a lock file or retrying with a new request ID can create two writers or two remote effects while making the original outcome harder to reconstruct."
    }
  ],
  "assessmentIds": ["ASM-0034", "ASM-0035", "ASM-0036"],
  "referenceIds": ["REF-0089", "REF-0090", "REF-0091", "REF-0092", "REF-0093", "REF-0094", "REF-0095", "REF-0096"],
  "contentStatus": "substantive-draft",
  "masteryBoundary": "publication-does-not-award-mastery",
  "lastReviewed": "2026-08-02",
  "reviewAfter": "2027-02-02",
  "limitations": [
    "The executable lab models remote calls, retries, idempotency, and concurrency deterministically; it does not prove behavior of a particular API, CI runner, filesystem, container runtime, Kubernetes controller, or cloud service.",
    "Examples target Bash, not generic `/bin/sh`. The lesson explains POSIX portability boundaries but does not claim every example runs under dash, BusyBox ash, ksh, zsh, macOS Bash 3.2, or non-GNU utilities.",
    "ShellCheck is required for project validation when available but is not installed by the lab. Static-analysis success is not a proof of semantics, security, or operational safety.",
    "Atomic rename examples address name visibility on one local filesystem; they do not by themselves guarantee crash durability, remote transaction atomicity, or distributed exactly-once delivery.",
    "The lesson does not award learner mastery. ASM-0036 requires answer-isolated work and human review of evidence, reasoning, safe execution, later recall, and unfamiliar transfer."
  ]
}
---

# Safe Bash automation: make failure visible, bounded, and recoverable

Bash can be a superb orchestration language. It can also turn one missing quote into the wrong argument list, one pipeline into a false success, and one retry into a duplicated production change. The difference is not whether the author remembers a collection of clever syntax. The difference is whether the program has explicit boundaries for data, state, failure, time, concurrency, secrets, and recovery.

Here is the sentence to keep: **Bash is a command orchestrator, not a safety system. Give every boundary a contract, then test that contract under failure.**

This chapter starts with first principles and finishes with production judgment. Every runnable exercise is local, offline, normal-user-only, and bounded. Production commands remain designs and evidence paths, not invitations to operate an employer system.

## What you see and first thought

### The green job with the wrong outcome

Imagine a CI job that prints this:

```text
processed=222 expected=240
complete=true
job_status=success
```

The dashboard is green. A report exists. Eighteen records are missing.

When you see this, do not begin with “Which line should I rerun?” Begin with: **Which contract declared success, and what real outcome was it supposed to prove?** A shell process returning zero is one signal. It is not evidence that every input remained one record, every child succeeded, every side effect happened once, the final artifact is complete, or the consumer can use it.

Walk the operation through five questions:

1. What exact data entered, and how were records separated?
2. What arguments did each command actually receive after Bash expansion?
3. Which command or pipeline status reached the caller?
4. Which state was already committed before the failure or interruption?
5. Which independent postcondition proves the user-visible result?

A restart is especially dangerous when question four is unanswered. If 222 remote changes happened and only the report failed, replaying 240 operations may create duplicates. If the producer failed after emitting 222 records, increasing retries may repeatedly publish an incomplete view. Preserve evidence before amplifying the same design.

### The tiny script that became infrastructure

A script often begins harmlessly:

```bash
#!/usr/bin/env bash
build
upload
```

Then requirements arrive: choose an environment, parse configuration, retry an API, write a status file, clean temporary state, handle Ctrl-C, run from CI, prevent two deployments, protect a token, and resume after interruption. The file is still called “a script,” but it now owns an interface and a state machine.

That is the point where engineering discipline must increase. Size alone is not the threshold. A 30-line deletion script can have a larger blast radius than a 500-line report generator. Ask what the program can change, what inputs it trusts, and what happens when it stops between any two lines.

### Signal-to-boundary map

| What you see | Put your mind here first | Do not conclude yet |
|---|---|---|
| `unbound variable` | Parameter contract and `nounset` context | That strict mode made all values safe |
| Green pipeline after an upstream error | Pipeline status selection and capture | That visible output is complete |
| `command not found` only in CI | Interpreter, PATH, image, working directory, startup files | That CI “lost” an installed tool |
| Filenames split or skipped | Record framing, quoting, `IFS`, globbing, leading dash | That the filesystem corrupted names |
| Duplicate operation after retry | Unknown outcome, idempotency key, reconciliation | That the remote system ignored a lock |
| Two runs overwrite one report | Lock scope, state reread, candidate publication | That a PID file proves mutual exclusion |
| Temporary state remains | Trap coverage, untrappable failure, startup recovery | That the trap simply needs more deletion power |
| Secret in CI logs | Arguments, environment, xtrace, response bodies, redaction | That masking one variable removes every copy |

### The first safe move

For an unfamiliar script, the first move is read-only:

```bash
# [READ-ONLY] Run from the intended repository as a normal user.
bash --version | head -n 1
pwd -P
id
bash -n -- ./script.sh
```

`bash --version` establishes interpreter family; `pwd -P` resolves the physical working directory; `id` establishes effective identity and groups; `bash -n` parses without executing. If any boundary differs, stop. Do not “solve” a missing command or denied path with `sudo`, and do not run a mutating path just to see what happens.

**Memory sentence:** a zero status is the shell's report, not the system's proof.

## Terms before commands

### Shell, Bash, script, process, and interpreter

A **shell** interprets a command language. **Bash** means Bourne-Again Shell, one specific shell with POSIX foundations and Bash-specific features. A **shell script** is a file of shell-language source. An **interpreter** is the program reading that source. A **process** is a running instance with an identity, environment, current directory, open file descriptors, signal state, and exit status.

These words matter because `/bin/sh script.sh` does not mean “run my Bash script.” On Ubuntu, `/bin/sh` commonly resolves to `dash`, a different shell. Arrays, `[[ ... ]]`, process substitution, `readarray`, and `PIPESTATUS` are Bash features. If the program needs Bash, say so in its shebang and validation, then invoke it as Bash in tests.

The **shebang** is the first line beginning with `#!`, such as `#!/usr/bin/env bash`. When an executable file is launched directly, the operating system uses it to select an interpreter. `env` searches `PATH`, which supports varied install locations but also makes `PATH` part of the trust and reproducibility contract. `bash script.sh` ignores the shebang for interpreter choice because Bash was selected explicitly.

### Token, grammar, word, argument, and option

A **token** is a unit Bash recognizes while reading source: a word or an operator such as `|`, `&&`, `;`, `>`, or `(`. **Grammar** determines how tokens form pipelines, lists, loops, functions, and other commands. A source **word** may later expand into zero, one, or several words. An **argument** is a final string passed to a command. An **option** is an argument a utility interprets as changing behavior, commonly because it begins with `-`.

A filename beginning with `-` is valid data. Without an option terminator, a utility may read it as an option. Where supported, `--` means “end options; following arguments are operands.” Quoting and `--` solve different problems: quoting preserves one argument; `--` tells the called utility how to classify it.

### Expansion and quoting

**Expansion** transforms source words. Bash performs brace expansion; tilde expansion; parameter, arithmetic, and command substitution; word splitting; filename expansion; then quote removal, with documented details and exceptions. The memorable risk boundary is this:

```text
source:        "$value"
parameter:     contents of value
quoted result: one argument, including empty

source:        $value
parameter:     contents of value
word split:    possibly several words
glob expand:   wildcard words may become matching pathnames
```

**Single quotes** preserve every character until the closing single quote; a single quote cannot appear inside that quoted region. **Double quotes** still allow parameter expansion, command substitution, arithmetic expansion, and selected backslash behavior, but suppress word splitting and filename expansion of the result. A backslash can remove special meaning from the following character under defined contexts.

The default is simple: quote parameter and command substitutions when one logical value must remain one argument. Important exceptions are deliberate multiargument expansions such as `"${array[@]}"`, which expands each array element as its own preserved argument.

### Parameter, variable, environment, and positional parameter

A **parameter** stores a value. A named parameter is a **variable**. **Positional parameters** are `$1`, `$2`, and so on; `$#` is their count, and `"$@"` expands them as separate quoted arguments. An **environment variable** is a name-value entry exported to child processes. A shell variable is not automatically exported.

Environment is convenient configuration, but it is ambient input. Validate it exactly as you validate arguments. Do not treat environment values as secret storage by default: child processes inherit exported values, diagnostic tooling may capture them, and careless `env` output can enter logs.

Parameter expansion can enforce contracts:

```bash
: "${RELEASE_ENV:?RELEASE_ENV must be set}"
readonly RELEASE_ENV
```

The `:` builtin does nothing beyond expansions and redirections. `${name:?message}` reports a missing or null value and prevents that simple command from succeeding. It does not validate that the value belongs to an approved enum, and it does not make the variable trustworthy.

### Standard streams, file descriptor, and redirection

A **file descriptor** is a small process-local number referring to an open file description or another input/output object. By convention, descriptor 0 is standard input, 1 is standard output, and 2 is standard error. **Redirection** changes where a descriptor points for a command.

```text
fd 0  stdin   machine or human input
fd 1  stdout  promised normal result
fd 2  stderr  diagnostics
```

`>` opens and truncates a file before the command runs. `>>` opens for append. `2>` changes descriptor 2. `2>&1` duplicates the destination currently referenced by descriptor 1. Order therefore matters:

```bash
command >run.log 2>&1   # both streams go to run.log
command 2>&1 >run.log   # stderr copies old stdout; then stdout moves to run.log
```

A redirection failure can prevent the command from executing. A successful command can still have its output write fail later, for example when a downstream pipe closes or storage fills. Treat streams as part of the interface, not decoration.

### Pipeline, list, exit status, and signal

A **pipeline** connects one command's standard output to the next command's standard input. The stages normally run in separate process environments and concurrently. An **exit status** is an integer result; zero conventionally means success and nonzero means some failure or alternate outcome. The meaning belongs to the program's documented contract.

Without Bash `pipefail`, a pipeline normally reports the last command's status. With `pipefail`, the pipeline fails if a stage fails, with Bash selecting the status of the rightmost failing command. `PIPESTATUS` is a Bash array holding individual stage statuses, but it must be copied immediately because a later command changes shell status state.

A **signal** is an asynchronous process notification such as TERM, INT, HUP, or KILL. A **trap** asks Bash to run code on selected trappable signals or pseudo-events such as EXIT and ERR. TERM is a request, not forced termination. KILL cannot be caught, blocked, or ignored, so no trap can guarantee cleanup after SIGKILL, host power loss, kernel failure, or abrupt runtime removal.

### Function, local variable, array, and subshell

A **function** groups shell commands and runs in the current shell environment unless another construct creates a child. Its status is normally the status of its last command unless it explicitly returns. `local` gives a function-scoped dynamic variable in Bash. A function should validate arguments and return a documented status rather than silently depending on globals.

An indexed **array** stores separate elements, preserving boundaries that a text string cannot. `items=("alpha" "quarter close" "")` stores three elements. Use `"${items[@]}"` to pass three arguments. `"${items[*]}"` produces one joined word using the first character of `IFS`; that is usually not a command argument list.

A **subshell** is a child shell environment created by constructs such as `( commands )` and often by pipeline stages. Variable changes inside do not update the parent. This is why code such as `producer | while read ...; do count=$((count+1)); done` may leave parent `count` unchanged. The data processed, files written, and external effects remain real even though the parent variable did not change.

### Record framing, delimiter, and IFS

A **record** is one logical input item. **Framing** is how a stream tells you where one record ends. Newline framing works only if newline is forbidden inside a record. Linux pathnames may contain every byte except NUL (`\0`) and slash separates components. Therefore newline is not a lossless arbitrary-path delimiter; NUL is.

`IFS` is the Internal Field Separator used by certain shell splitting and `read` behavior. `IFS= read -r line` is the standard shape for reading a line without trimming default whitespace or treating backslashes as escapes. It still defines a line record, so the producer's contract must forbid embedded newline. For arbitrary paths, pair producer `-print0` or equivalent NUL output with a NUL-aware consumer.

### Idempotency, retry, timeout, and reconciliation

An operation is **idempotent** when repeating the same logical request causes no extra effect beyond the first successful application. Setting a field to a desired value can be idempotent; incrementing it is not. An **idempotency key** names the logical request so a state owner can deduplicate attempts.

A **retry** is another attempt. A **timeout** means an observer did not receive completion inside a time budget; it does not mean a remote mutation failed. **Reconciliation** compares desired intent with authoritative actual state and decides what remains. When a network response is lost after the server commits, reconciliation by operation identity is the safe bridge between timeout and retry.

### Lock, race, atomicity, transaction, cleanup, and rollback

A **race condition** means the result depends on timing between operations. A **lock** is coordination state used by cooperating actors. Linux `flock` provides advisory locking around a file or open descriptor; a process that ignores it can still write. A local lock does not coordinate another host or create remote exactly-once behavior.

**Atomicity** means an operation is observed as indivisible under a stated boundary. Renaming a file over another name on the same local filesystem can give readers old-or-new name visibility. It is not automatically durable after power loss and does not make a remote API transaction atomic.

A **transaction** groups changes with a defined commit and abort model. Bash options do not create transactions. **Cleanup** removes temporary resources. **Rollback** restores previous committed state or applies a compensating action. Deleting a temporary candidate is cleanup; restoring the former deployment is rollback. Keep the distinction visible in scripts and runbooks.

### Portability and dialect

A shell **dialect** is the language variant a script targets. POSIX `sh` defines a portable baseline. Bash adds arrays, `[[ ]]`, process substitution, `mapfile` or `readarray`, `PIPESTATUS`, `BASH_SOURCE`, and more. A script is not portable because its shebang says `sh`; it is portable only when its constructs, utilities, flags, and tested behavior fit the declared environments.

GNU utility flags such as `stat --printf` or `readlink -e` also affect portability. If Ubuntu 24.04 is the contract, use and test the available GNU behavior honestly. If multiple platforms are required, test each platform or simplify to the common contract. Do not hide incompatibility behind “it should work.”

**Memory sentence:** quote to preserve one argument; frame to preserve one record; neither replaces validation.

## Architecture map

### Diagram 1: source to decision

Read left to right:

```text
[source bytes]
      |
      v
[tokens + grammar] -- evidence: bash -n, first parser error
      |
      v
[expansions]        -- evidence: argc, printf '%q', quoted arrays
      |
      v
[redirections]      -- evidence: fd map, stdout/stderr, target metadata
      |
      v
[lookup + execute]  -- evidence: command -V, PATH, identity, cwd, env
      |
      v
[wait + statuses]   -- evidence: $?, PIPESTATUS, signal classification
      |
      v
[caller decision]   -- evidence: verified postcondition, not status alone
```

Text alternative: Bash does not pass source text straight to a utility. It parses grammar, expands words, applies redirections, resolves commands, runs them in an environment, and selects status. The caller then needs an independent outcome check. A defect at each boundary has different evidence.

### Diagram 2: automation control plane and state plane

```text
CONTROL PATH
caller -> parse CLI -> validate -> acquire local lock -> run step -> classify result

STATE PATH
intent manifest -> current-state reread -> operation ID -> candidate -> validate -> publish
                                           |
                                           +-> external owner -> receipt/reconcile

EVIDENCE PATH
run ID -> sanitized step logs -> attempt status -> outcome receipt -> postcondition
```

The control path decides what to do. The state path records intent and outcomes. The evidence path lets another engineer reconstruct why the control decision was reasonable. Mixing them creates common failures: logs become state, a PID file becomes a lock, an exit code becomes verification, or a temporary filename becomes authorization.

### Diagram 3: trust and ownership boundaries

```text
untrusted or variable                    trusted only after validation
---------------------                    -----------------------------
arguments -----------\                    normalized enum / integer
environment ----------> [validator] ----> canonical allowlisted root
filesystem names -----/                    quoted array of exact records
API response --------/                     classified structured result

secret provider -> [narrow descriptor/client] -> remote service
                    |                         |
                    +-> redacted logs        +-> authoritative state
```

Text alternative: arguments, environment, pathnames, and external responses are inputs, not code and not authorization. A validator converts accepted inputs into narrow internal forms. Secrets travel through a separate restricted channel and are redacted from evidence. The external service remains authoritative for remote state.

### When Bash is the right tool

Bash is usually a good choice when all of these are true:

- the work is primarily invoking a small set of stable command-line tools;
- the control flow is understandable as a short sequential state machine;
- data is simple arguments, line records with a declared constraint, or pathname arrays;
- concurrency is absent or limited to one clear local critical section;
- tests can execute the whole interface cheaply;
- the blast radius is bounded and recovery is explicit.

Move the core toward Python, Go, or another general-purpose language when JSON or other structured data becomes central, protocol and authentication logic expands, concurrency becomes substantial, durable state has many transitions, library APIs are better than subprocesses, or types and test tooling would make invariants clearer. Bash can remain a small launcher. The decision is an operability trade-off, not a judgment that Bash is “bad.”

**Memory sentence:** design the script as three paths—control, state, and evidence—then keep their contracts separate.

## Request or state path

A reliable script has a lifecycle you can point to. “It runs commands” is too vague to review. Use this path:

```text
1 receive intent
2 establish runtime
3 validate inputs
4 acquire coordination boundary
5 reread current state
6 record logical operation identity
7 make one bounded attempt
8 classify definite success, definite failure, or unknown
9 reconcile when unknown
10 build and validate candidate state
11 publish or compensate
12 verify the real postcondition
13 emit sanitized evidence
14 release and prove cleanup
```

### 1. Receive intent without turning data into code

A safe command-line interface rejects ambiguity. Prefer subcommands and explicit options:

```text
reconciler plan  --manifest PATH --environment staging
reconciler apply --manifest PATH --environment staging --operation-id ID
reconciler status --operation-id ID
```

The parser should reject unknown flags, missing values, unsupported enums, repeated singleton flags, and extra positional arguments. A value is never evaluated as shell source. Avoid `eval`, `bash -c "$user_text"`, dynamically constructed redirections, or concatenated remote commands. If the task genuinely accepts a program, that is a different trust product requiring sandboxing and authorization—not ordinary input parsing.

Use a `while` and `case` parser for a small Bash CLI:

```bash
parse_cli() {
  local environment='' manifest=''

  while (($# > 0)); do
    case $1 in
      --environment)
        (($# >= 2)) || { printf '%s\n' 'error=missing-environment' >&2; return 64; }
        environment=$2
        shift 2
        ;;
      --manifest)
        (($# >= 2)) || { printf '%s\n' 'error=missing-manifest' >&2; return 64; }
        manifest=$2
        shift 2
        ;;
      --)
        shift
        break
        ;;
      -* )
        printf 'error=unknown-option option=%q\n' "$1" >&2
        return 64
        ;;
      *)
        printf 'error=unexpected-argument argument=%q\n' "$1" >&2
        return 64
        ;;
    esac
  done

  (($# == 0)) || return 64
  case $environment in staging|production) ;; *) return 64 ;; esac
  [[ -n $manifest ]] || return 64
}
```

This is a teaching fragment, not a complete production parser. Notice the contract: check a value exists before reading `$2`; store it without `eval`; use arithmetic context for counts; quote data at output; and assign a usage-error status of 64. `[[ ... ]]` is Bash syntax and does not perform word splitting or pathname expansion on ordinary operands, but variables must still be handled deliberately when patterns or regular expressions are involved.

### 2. Establish the runtime before trusting ambient state

Record interpreter and dependency identity. Set a restrictive `umask` before creating files. Resolve the script directory without trusting the caller's working directory. Keep required configuration explicit.

```bash
#!/usr/bin/env bash
set -Eeuo pipefail
umask 077

SCRIPT_DIRECTORY=$(CDPATH='' cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
readonly SCRIPT_DIRECTORY
```

`BASH_SOURCE[0]` identifies the current Bash source file; `dirname` obtains its parent portion; `cd --` changes the subshell's directory; `CDPATH=''` prevents directory-search output and alternate resolution; `pwd -P` returns a physical path. Command substitution runs this in a subshell, so the caller's directory does not change. Every expansion that should remain one path is quoted.

This common pattern still has assumptions. The file can move between resolution and use. Symbolic links may be intentionally resolved or intentionally preserved depending on the product. A hostile parent directory can change entries. Decide whether deployment ownership makes that acceptable; do not call the pattern a complete secure path resolver.

### 3. Validate by type and boundary

Validation should narrow input into a form later code can safely use. Examples:

- enum: exact `case` alternatives such as `dev|staging|prod`;
- unsigned integer: lexical digits, range, and unit, not merely arithmetic coercion;
- identifier: length plus an allowlisted alphabet tied to its actual protocol;
- path: approved parent, canonical location, type, owner, permissions, symlink policy, link count, and size;
- file: expected schema, encoding, record count, and maximum bytes;
- environment: presence, origin, sensitivity, and whether export is needed.

For a decimal count:

```bash
validate_count() {
  local value=${1-}
  [[ $value =~ ^[0-9]+$ ]] || return 64
  ((10#$value >= 1 && 10#$value <= 1000)) || return 64
}
```

The lexical check excludes signs and non-digits. `10#` forces base ten so a leading zero is not interpreted using another base. The accepted range prevents a syntactically valid but operationally dangerous value. State the unit at the interface: `--timeout-seconds`, not `--timeout` with a hidden guess.

### 4. Acquire a lock, then reread state

Lock acquisition and state observation are ordered. If you read a manifest, wait for a lock, then write based on the old read, another actor may have changed it while you waited.

```text
wrong: read version 7 -> wait -> acquire -> write version 8 from stale view
right: acquire -> read current version 8 -> decide -> write version 9 -> release
```

Use a descriptor-scoped advisory lock when cooperating processes share the same supported local filesystem. Decide whether contention should fail immediately, wait a bounded interval, or enqueue elsewhere. Never infer ownership from an old PID without checking process identity and namespace, and never delete a lock path as a way to release another process's lock.

### 5. Record intent and logical identity before a remote effect

For a remote mutation, persist a stable logical operation ID before sending. One retry must reuse that ID. The state owner must define how long it remembers deduplication keys and what response a duplicate receives.

```text
operation_id=release-2026-08-02-build-1842
desired_state=deployed
attempt=1
status=attempting
```

A timestamp alone is often a poor key: clocks can collide or differ, and a retry with a new timestamp becomes a new logical request. A random UUID can be suitable if created once and durably attached to intent. A hash can be suitable only if canonical input and collision behavior are defined. The key is an application protocol decision, not shell syntax.

### 6. Bound the attempt and classify the outcome

Every blocking command needs an upper time budget derived from the caller's deadline. `timeout` can bound a local child, but its signal semantics, process group behavior, and exit statuses must be understood. A CLI's own connect and request timeout controls are often more precise for network clients.

Classify results into at least:

| Class | Example | Immediate policy |
|---|---|---|
| success | accepted receipt with expected operation ID | verify authoritative state |
| permanent caller error | invalid input, authentication, authorization | do not retry until input or authority changes |
| conflict | version mismatch or already different desired state | reread and reconcile |
| throttled | explicit rate limit and safe retry guidance | bounded backoff within deadline |
| transient dependency | reviewed server or transport failure before acceptance | bounded retry if idempotent |
| unknown mutation outcome | timeout or lost response after request may have arrived | query by operation ID before retry |

Do not retry an error merely because it is nonzero. Retrying a permission error wastes capacity. Retrying a syntax error produces noise. Retrying an unknown non-idempotent mutation can duplicate the effect.

### 7. Reconcile and publish

Reconciliation asks the authoritative owner what actually exists. For local files, that may mean reopening current metadata and content under a lock. For an API, query by logical operation ID or desired resource identity. For Kubernetes, inspect desired and observed generation plus conditions rather than assuming a timed-out client request did nothing.

For a local report, use a private candidate in the same directory as the final file when same-filesystem atomic rename is the contract:

```text
create candidate securely
  -> write complete bytes
  -> validate schema, count, permissions, and size
  -> preserve previous final
  -> rename candidate over final
  -> reopen final and verify consumer-facing invariant
```

Do not write directly to a shared final filename. Do not validate only that a file is nonempty. The validation must match what the consumer needs: exact schema, unique keys, required record count, ordering only when relevant, permissions, ownership, and freshness.

### 8. Verify, report, and clean

Verification observes a postcondition through a path independent enough to catch the failed mechanism. If the script wrote a report, have the real parser read it. If it requested a deployment, query the controller or perform an approved health transaction. If it changed permissions, read them from the target. “The function returned zero” is not independent.

Preserve the original status before cleanup:

```bash
main "$@"
main_status=$?
cleanup_status=0
cleanup || cleanup_status=$?

if ((main_status != 0)); then
  exit "$main_status"
fi
exit "$cleanup_status"
```

With `errexit`, production code normally wraps this in deliberate contexts so `main_status` can be captured. Decide status precedence: a main failure should not be hidden by cleanup success, and a cleanup failure after main success may deserve its own nonzero status. Log both.

**Memory sentence:** acquire, reread, identify, attempt, classify, reconcile, publish, verify—never replace that path with “run and retry.”

## Failure zoom

### Failure 1: one value became several arguments

Start with a synthetic variable:

```bash
value='quarter close *.log'
```

Unsafe:

```bash
process $value
```

The failure path is:

```text
value bytes: quarter close *.log
        |
        v
parameter expansion
        |
        v
word splitting: [quarter] [close] [*.log]
        |
        v
filename expansion: [quarter] [close] [a.log] [build.log] ...
        |
        v
process receives an environment-dependent argument vector
```

Safe when the entire value is one argument:

```bash
process "$value"
```

Safe when the program already has distinct array elements:

```bash
items=('quarter close' '*.log' '')
process -- "${items[@]}"
```

The quotes around the array expansion preserve three elements, including the empty third element. `--` is passed to `process`; it helps only if that program documents it as the end-of-options marker. Neither construct validates that the operands are authorized.

### Failure 2: command substitution erased a record protocol

This loop is not a line reader:

```bash
for file in $(find ./input -type f); do
  handle "$file"
done
```

Command substitution removes trailing newline characters, then the unquoted result undergoes word splitting and pathname expansion. Even if `"$file"` is quoted inside the loop, the record was already damaged.

If records are guaranteed not to contain newline:

```bash
while IFS= read -r record; do
  handle "$record"
done < approved-lines.txt
```

If records are arbitrary Linux pathnames:

```bash
while IFS= read -r -d '' path; do
  handle -- "$path"
done < <(find -- ./input -type f -print0)
```

There is a subtle additional boundary: process substitution is asynchronous, and the loop's status does not automatically provide the producer's status in an easy portable contract. For a safety-critical inventory, separate discovery from action, capture and validate the producer outcome, then consume a securely stored NUL-delimited candidate or use a tool whose single invocation expresses the operation safely.

### Failure 3: the last pipeline stage looked healthy

```bash
produce_records | tee candidate.txt
```

Suppose the producer emits 222 records and exits 23. `tee` writes what it received and exits zero. Without `pipefail`, the pipeline normally returns zero. With `pipefail`, the pipeline returns nonzero, but `candidate.txt` still exists and contains partial data.

```text
producer: writes partial bytes -> exits 23
              |
              v
tee: receives EOF -> writes partial candidate -> exits 0
              |
              v
status policy: 0 without pipefail; nonzero with pipefail
              |
              v
publication policy must still reject partial candidate
```

`pipefail` improves failure visibility; it does not create rollback. A safe design stores candidate output away from the shared final name, captures the failure, rejects or quarantines the candidate, and preserves the previous complete artifact.

### Failure 4: strict mode changed control flow but not state

The phrase “strict mode” commonly refers to:

```bash
set -Eeuo pipefail
```

Decode it:

- `-e`, or `errexit`, exits after some unhandled nonzero statuses, with documented grammar-context exceptions;
- `-E`, or `errtrace`, lets an ERR trap be inherited in more function, command-substitution, and subshell contexts;
- `-u`, or `nounset`, treats many expansions of unset variables as errors;
- `pipefail` changes a pipeline's selected status when a stage fails.

These options are valuable as defect detectors. They are not a complete error model. Expected nonzero outcomes must appear in explicit branches:

```bash
if output=$(query_state); then
  printf '%s\n' "$output"
else
  query_status=$?
  printf 'error=query-failed status=%d\n' "$query_status" >&2
  return "$query_status"
fi
```

A failed command can already have created files or remote side effects. `errexit` will not undo them. It can also stop earlier than expected when arithmetic expressions return status one—`((counter++))` evaluates to the old value and returns failure when that value is zero. Prefer control flow you can explain and test rather than reasoning from a slogan.

### Failure 5: cleanup trusted a mutable string

Dangerous:

```bash
trap 'rm -rf "$work_dir"' EXIT
```

The quotes prevent splitting, but they do not prove that `work_dir` is the correct root. It might be empty, changed, a symlink, an unexpected parent, foreign-owned, or contain unreviewed children. EXIT also runs in contexts where initialization may be incomplete.

The safer pattern is capability-like: create one private root securely, store it in a readonly variable, write an exact sentinel, allowlist every artifact, revalidate root and children, remove named regular files, `rmdir` empty directories, then `rmdir` the exact root. Refuse cleanup if any invariant differs. A refusal leaves evidence for a human; a broad delete can destroy evidence and unrelated data.

### Failure 6: timeout became blind retry

```text
client sends operation ID X
server commits X
response is lost
client timeout fires
client retries as new operation ID Y
server commits Y
```

The timeout is an observation at the client deadline. The server's commit is state elsewhere. A local trap cannot roll it back. The recovery path is to query operation X or the desired resource state. If X committed, record completion. If X was definitely rejected and the error is transient, retry X within budget. If the result remains unknown, stop or escalate according to the risk; do not manufacture certainty.

**Memory sentence:** quoting prevents argument mutation; status handling exposes failure; state design prevents failure from becoming damage.

## Internals and state ownership

### The shell's operation order

At a useful level, Bash reads input, recognizes tokens and operators while applying quoting rules, parses grammar, performs expansions, applies redirections, executes the command, waits when required, and makes a status available. The exact manual defines nuances, but this model lets you locate most automation bugs.

Consider:

```bash
result=$(generate "$source") >"$candidate"
```

The assignment value and redirection are prepared as part of a simple command. Command substitution runs `generate` in a subshell environment and removes trailing newlines from its captured standard output. The captured output is assigned to `result`; because assignment context differs from an ordinary unquoted argument context, it is not handled exactly like `command $result`. The redirection creates or truncates the candidate even though no external command name appears. If expansion or redirection fails, assignment and file state can differ from what a reader expects. Test the exact grammar, not a simplified mental paraphrase.

### Quoting is syntax, not sanitization

Quoting tells the shell where one word boundary belongs. It does not make a string safe for every receiving language. A quoted value can still be:

- an unauthorized filesystem path;
- an option if the utility sees it before `--`;
- a regular expression when placed on the regex side of `[[ =~ ]]`;
- an SQL value when interpolated into SQL text;
- YAML or JSON with broken structure when concatenated;
- a remote-shell program when passed to `ssh host "$value"`;
- a secret that should not appear in arguments or logs.

At every boundary, use that language's real data interface: argv elements for a local process, a JSON serializer for JSON, parameterized queries for SQL, an API client for HTTP, and separately transferred input or fixed remote programs for remote execution. “I quoted it” is only a claim about one shell parsing boundary.

### Function state and status

Functions share the shell's variables, options, current directory, and descriptors unless explicitly contained. This makes them lightweight and also makes hidden coupling easy.

```bash
publish_candidate() {
  local candidate=${1:?candidate required}
  local destination=${2:?destination required}

  validate_candidate "$candidate" || return 65
  mv -- "$candidate" "$destination" || return 74
}
```

A good function takes explicit inputs, declares locals, produces a documented output channel, returns documented statuses, and leaves global state unchanged unless that mutation is its purpose. Do not use standard output for both a machine value and chatty logs. Command substitution captures standard output, so one debug line can corrupt the caller's data.

If a function must change directory, either save and restore it with checked statuses or run the entire operation in a subshell `( cd ... && work )`. A subshell contains shell variables and directory changes, but it does not contain external side effects such as files, API calls, or signals sent to other processes.

### Arrays and maps

Indexed arrays preserve an ordered list of elements. Associative arrays map string keys to values in Bash. They are useful for modest configuration and lookup state, but not a replacement for a validated structured-data parser.

```bash
declare -a command=(curl --fail-with-body --silent --show-error)
command+=(--connect-timeout "$connect_seconds")
command+=(--max-time "$request_seconds")
command+=(-- "$url")
"${command[@]}"
```

Building argv as an array prevents a value from becoming shell grammar. Do not later collapse it into a string and `eval` it. Note that `curl` and network execution are conceptual here; the lab makes no call. Whether `--` is valid and what timeout flags mean must be checked against the actual tool version before production use.

### Redirection and descriptor ownership

Redirections are applied in order. Opening with `>` truncates before the child completes. A robust script often reserves descriptors for a lock or log, but descriptor lifetime must be clear. A lock associated with descriptor 9 normally lasts while an appropriate open file description remains held; accidentally inheriting it into long-lived children can extend the critical section.

Standard output should carry the promised result. Standard error should carry diagnostics. A caller can then capture them independently:

```bash
stdout_file=$(mktemp)
stderr_file=$(mktemp)
if command >"$stdout_file" 2>"$stderr_file"; then
  status=0
else
  status=$?
fi
```

This fragment needs guarded temporary creation, cleanup, ownership validation, and explicit parent selection in real automation. Its teaching point is that output, error, and status are three evidence channels. Do not merge them by default and later try to parse the mixture.

### Traps, ERR, and reentrancy

An EXIT trap runs when a Bash process exits through normal or many error paths. It does not run after SIGKILL or power loss. An ERR trap is subject to the same grammar contexts that shape `errexit`, and it is not a universal exception handler. Traps run in the shell's state at that moment; cleanup variables may be unset or partially initialized.

Design cleanup as an idempotent function and guard against repeated entry:

```bash
cleanup_started=0
cleanup() {
  local original_status=$?
  ((cleanup_started == 0)) || return "$original_status"
  cleanup_started=1
  trap - EXIT INT TERM
  # Validate and remove exact invocation-owned artifacts here.
  return "$original_status"
}
trap cleanup EXIT INT TERM
```

This pattern illustrates reentry control and status preservation, not a complete signal state machine. Returning from an INT or TERM trap can allow work to continue; exiting from it may invoke EXIT as well. Production code should use separate signal handlers that record the signal and choose a safe stop boundary, plus an EXIT handler for final cleanup. Test each signal path.

### Temporary state and atomic publication

Never construct a predictable temporary filename such as `/tmp/report.$$` and assume it is safe. `mktemp` creates a new name using exclusive creation. Set `umask 077`, choose an approved parent, validate the returned object, and keep its path immutable.

For a file consumed by other processes:

1. create a candidate securely in the destination directory;
2. write through a descriptor or exact path;
3. check the writer's status;
4. validate content, bytes, owner, mode, and schema;
5. optionally preserve or version the previous artifact;
6. rename within the same filesystem;
7. reopen through the consumer path and verify.

This gives atomic name visibility under that filesystem's rename contract. Crash durability is stronger: data and directory metadata may need explicit synchronization, and filesystems or network mounts differ. Document which guarantee you actually need.

### Retry arithmetic and capacity

Exponential backoff commonly grows a delay by a factor, capped at a maximum, with random **jitter** so clients do not retry in lockstep. The capacity equation matters more than the loop syntax.

If 1,000 jobs fail together and each makes three immediate retries, the dependency can receive roughly 3,000 additional attempts while already unhealthy. With per-attempt time `t`, backoff delays `d_i`, and `n` attempts, the caller's worst-case time is approximately:

```text
total <= sum(attempt_timeout_i) + sum(backoff_i) + local overhead
```

That total must fit inside the job or request deadline. A retry budget also needs a maximum attempt count, maximum elapsed time, retryable status set, idempotency guarantee, and cancellation behavior. Jitter reduces synchronization; it does not create capacity.

### Locking and concurrency

A **critical section** is the portion that must not overlap for shared state to remain valid. Keep it small but complete. Locking only the final `mv` may still allow two processes to make duplicate remote calls. Locking an entire slow remote operation can serialize too much and create queueing. The correct boundary depends on state ownership.

For local desired-state reconciliation:

```text
acquire local lock
  -> reread intent and receipts
  -> reserve or confirm operation ID
  -> release if remote work may run independently
  -> perform idempotent remote attempt
  -> reacquire
  -> reconcile authoritative result
  -> publish receipt
  -> release
```

This is more complex than one long lock because the remote system is another state owner. A database transaction, lease, CI concurrency group, Kubernetes Lease, or server-side idempotency store may be the proper distributed primitive. A local `flock` is not distributed coordination.

### Portability choices

Choose one of two honest policies:

- **Bash policy:** require and test a Bash version; use arrays and Bash constructs where they make correctness clearer.
- **POSIX shell policy:** target the standard language and a declared utility set; run tests under every required shell and platform.

Do not write Bash, name the file `.sh`, run ShellCheck as `sh`, and call it portable. Do not replace arrays with unsafe space-separated strings just to remove a Bash feature. Correctness on the required platform is better than imaginary portability.

**Memory sentence:** every shell feature has an owner—parser, process, filesystem, or remote service—and cannot guarantee state outside that owner.

## Evidence table

| Question | Evidence | Risk and scope | What it proves | What it cannot prove |
|---|---|---|---|---|
| Which runtime executes this? | `bash --version`, OS release, `id`, `pwd -P`, `command -V` | Read-only, current shell | Displayed versions, identity, directory, resolution | Semantic correctness or production parity |
| Can Bash parse it? | `bash -n -- script.sh` | Read-only, one file | This interpreter found no syntax error | Runtime, expansion, side-effect, or portability safety |
| What argv crossed the boundary? | wrapper printing `$#` and `printf '%q'` for `"$@"` | Read-only synthetic input | Argument count and byte-representable rendering | Authorization or downstream interpretation |
| Were records preserved? | producer count, delimiter contract, array count, per-record IDs | Read-only or bounded fixture | Tested record framing | Concurrent file stability or producer completeness without status |
| Which pipeline stage failed? | captured `$?`, immediate `PIPESTATUS`, each stderr | Read-only synthetic run | Status selected for that invocation | Rollback or absence of partial output |
| What did strict options do? | `set -o`, isolated branch tests, statuses | Read-only child shell | Option state and tested grammar behavior | Transactionality or total failure coverage |
| Is a path inside scope? | `readlink -e`, `stat` type, UID, mode, links, parent, sentinel | Read-only snapshot | Displayed invariants at sample time | Immunity to later race or content correctness |
| Did timeout expire? | wrapper duration, status, child signal log | Bounded synthetic child | Local deadline behavior | Remote mutation outcome |
| Who coordinates local writers? | nonblocking lock result, descriptor lifetime, concurrent test | Bounded local file | Cooperation in tested lock domain | Cross-host or noncooperating exclusion |
| Was a retry safe? | stable operation ID, authoritative query, one receipt, effect count | Read-only query plus approved test | Tested idempotency/reconciliation outcome | Universal exactly-once behavior |
| Did publication succeed? | candidate validation, rename result, consumer reopen | Bounded local fixture | Tested old-or-new publication invariant | Crash durability or remote atomicity |
| Did cleanup finish safely? | exact allowlist removal, `rmdir`, absence check | Bounded lesson root | Registered state is absent | Absence of unrelated state outside scope |

### Evidence quality ladder

Label each statement:

1. **Observation:** “Pipeline status was 23 at 11:05:10 in run R7.”
2. **Documented fact:** “Under this Bash option, the pipeline selects a nonzero stage status.”
3. **Calculation:** “240 expected minus 222 terminal receipts equals 18 unresolved records.”
4. **Inference:** “The 18 names correlate with spaces, so record splitting is likely.”
5. **Hypothesis:** “Unquoted command substitution caused the omissions.”
6. **Unknown:** “Whether the timed-out remote request committed.”

An engineer becomes trustworthy by keeping those categories separate. A hypothesis becomes stronger when a controlled reproduction predicts the same argument count and missing set. It becomes a root cause only after the causal mechanism, incident evidence, and prevention test align.

### Timing and sampling

An exit status is an event result, not a rate. A lock check is a point-in-time observation. A retry counter is cumulative within a run unless labeled otherwise. Duration is an interval. A file size is a point-in-time byte count. A percent success metric needs numerator, denominator, population, and time window.

Write units into names:

```text
attempt=2
attempt_timeout_seconds=10
elapsed_milliseconds=1842
records_expected=240
records_terminal=222
retryable=false
```

Avoid `timeout=10`, `time=1842`, or `success=99.9` without meaning. Future operators should not guess whether a number is milliseconds, seconds, count, percent, or ratio.

## Command decoders

### Decoder: `bash -n -- ./script.sh`

Question: can this Bash parser read the whole file as valid syntax without executing it?

```text
bash  select the Bash interpreter explicitly
-n    read commands and check syntax; do not execute them
--    end Bash options
./script.sh  the exact file operand
```

A successful parse usually prints nothing and returns zero. A failure may look like this illustrative output:

```text
./script.sh: line 27: syntax error near unexpected token `fi'
./script.sh: line 27: `fi'
```

Start with the first meaningful parser error, often just before the reported token: an unclosed quote, missing `then`, malformed redirection, or missing delimiter can make a later `fi` look wrong. Parsing does not execute expansions or confirm that a command exists.

### Decoder: `printf '%q'`

`printf` is a Bash builtin and also exists as an external utility. Bash's `%q` format produces a shell-reusable representation of an argument. It helps humans see spaces, tabs, empty values, and metacharacters:

```text
original argument       illustrative %q
quarter close.log       quarter\ close.log
empty string            ''
literal asterisk        \*
embedded newline        $'left\nright'
```

Do not use `%q` as a cross-language serialization or a portable POSIX format. Do not feed a stored `%q` string to `eval`. For evidence, pair it with `argc` and a run ID, and protect output if values can contain secrets.

### Decoder: `read`, `readarray`, and `IFS`

`IFS= read -r line`:

- the temporary empty `IFS` assignment prevents leading or trailing default whitespace trimming;
- `read` consumes one delimiter-terminated record into variables;
- `-r` stops backslash from escaping the next character;
- `line` receives the record without the delimiter.

A final unterminated line can make `read` return nonzero while still assigning data. If the contract accepts it, handle that branch explicitly:

```bash
while IFS= read -r line || [[ -n $line ]]; do
  handle "$line"
done < "$input"
```

`readarray -d '' -t paths` reads records separated by NUL into a Bash array. `-d ''` selects NUL in Bash, and `-t` removes the delimiter. This is Bash-specific. Capture the producer's failure in a design where its status is observable; process substitution can otherwise make a failed producer easy to miss.

### Decoder: pipeline status and `PIPESTATUS`

Use a child shell to learn without changing the interactive shell's options:

```bash
bash -c '
  set +e
  set -o pipefail
  { printf "record\n"; exit 23; } | sed -n "1p"
  statuses=("${PIPESTATUS[@]}")
  printf "stages=%s\n" "${statuses[*]}"
'
```

The braces group a producer in one pipeline stage. It writes one record, then returns 23. `sed` reads and prints the record and can return zero. With `pipefail`, the pipeline status becomes nonzero. The array must be copied immediately: even `printf` is another command that updates status-related state.

A downstream command that intentionally stops early, such as `head -n 1`, may close the pipe and cause an upstream writer to receive SIGPIPE. Under `pipefail`, that can make a pipeline fail even when “first line only” was the intended consumer outcome. Design and test that case rather than disabling `pipefail` globally.

### Decoder: strict options

Inspect current option state:

```bash
set -o
shopt -p inherit_errexit 2>/dev/null || true
```

`set -o` prints option names and on/off state. `shopt` controls Bash options beyond `set`; the example treats absence or disabled state as an expected observation, but `|| true` also erases distinction unless you capture output and status deliberately.

`nounset` has edge cases around optional parameters and arrays. Use `${1-}` when absence is allowed, `${1:?message}` when required, and test empty separately when empty is invalid. `errexit` is suppressed in several conditional contexts because nonzero is used for branching. The correct question is not “Is `-e` on?” It is “What status can this command return in this grammar position, and what explicit branch owns each expected result?”

### Decoder: `timeout`

```text
timeout                  wrapper program
--signal=TERM            signal sent when duration expires
--kill-after=2s          later send KILL if the command remains
5s                       initial duration budget
command ...              child program and its exact argv
```

GNU `timeout` commonly uses status 124 when the duration expires unless options preserve another status. Status 125 indicates the wrapper itself failed; 126 or 127 can describe command invocation problems; signal-related statuses may appear depending on options and child behavior. Consult the installed manual and test your exact flags.

The wrapper's timeout does not tell you whether a remote service committed. It also may not automatically manage every detached descendant. Prefer the called client's native request deadline when it has a clearer protocol contract, and combine that with an overall job budget.

### Decoder: `flock`

```bash
exec 9<"$ATLAS_PRIVATE_DIR"
flock -n 9
```

After validating that `ATLAS_PRIVATE_DIR` is the approved absolute, current-UID-owned, non-symlink mode-`0700` directory and confirming the opened descriptor still identifies that directory, `exec 9<` opens the directory without creating or truncating a predictable file. `flock -n 9` requests an exclusive lock without waiting. Success means this process acquired an advisory lock recognized by cooperating users of the same lock domain. Failure means contention or another error; choose distinct status handling.

The directory remains after release because it is caller-owned state and lock ownership is associated with the open file description, not “path exists.” Replacing or deleting a lock path does not safely unlock another holder; it can split contenders across different filesystem objects. Filesystem support varies, especially on network filesystems, so test the actual storage boundary.

### Decoder: `stat` and `readlink`

For GNU `stat`:

```text
%F  file type in words
%u  numeric owner user ID
%a  permission bits in octal
%h  hard-link count
%s  size in bytes
%n  displayed name
```

`readlink -e -- path` resolves every component to a canonical existing path. Failure can mean absence, permission denial, or an unresolved component. A check is a snapshot; a hostile directory can change after it. Reduce races with private directories, ownership, restrictive modes, descriptor-relative operations where appropriate, and minimal time between validation and mutation.

### Decoder: exit-code contracts

Do not return one generic status for everything. A small CLI might document:

| Status | Meaning | Caller action |
|---:|---|---|
| 0 | requested operation verified | proceed |
| 64 | usage or validation error | fix input; do not retry unchanged |
| 65 | candidate data invalid | inspect producer or schema |
| 69 | dependency unavailable before accepted mutation | retry only within policy |
| 73 | local state cannot be created | inspect ownership, mode, capacity |
| 74 | local input/output failure | preserve state; inspect exact I/O boundary |
| 75 | temporary contention or reviewed transient condition | bounded retry or reschedule |
| 78 | configuration error | correct configuration |

These numbers resemble established software conventions but become valid only when this program documents and tests them. Status range is limited; signals and wrappers can transform it. Put detailed reason codes in sanitized structured stderr or a result artifact while keeping exit status stable enough for automation.

### Decoder: xtrace without secret leakage

`set -x` prints expanded commands, commonly to standard error. That makes it dangerous around tokens, headers, signed URLs, decrypted files, and secret-bearing environment values. Do not assume a CI masking feature catches transformations or substrings.

If tracing is necessary, route it deliberately with `BASH_XTRACEFD` to a restricted descriptor, use a safe `PS4` that contains run context but no secrets, and disable tracing before secret expansion. Better, emit explicit structured step logs so observability does not depend on source-level tracing. Validate logs with secret-shaped synthetic canaries, never real secrets.

**Memory sentence:** every command decoder ends with what the evidence cannot prove; that sentence prevents most overconfident automation fixes.

## Decision path

### Step 0: decide whether to run anything

Before debugging by execution, answer:

- Is the target synthetic, local, disposable, or production?
- What identity and namespace will execute?
- Which files, processes, APIs, and users can the script change?
- Is the operation reversible, compensatable, or irreversible?
- Does a prior attempt have an unknown outcome?
- Can the same evidence be gathered read-only?

If the script can delete, deploy, rotate credentials, change access, or call a paid service, do not run it merely because it has a `--dry-run` flag. Inspect what dry-run actually suppresses. Some tools still authenticate, enumerate, write caches, acquire locks, or trigger validation calls. Establish authorization and blast radius separately.

### Step 1: frame the failed operation

Write one sentence with actor, operation, target, time, expected result, actual result, and boundary:

```text
CI run R1842, executing as UID 1000 in image digest D, attempted to publish
240 release records to local path P at 10:14 UTC; the job exited 0 but the
consumer parsed 222 unique records and producer stderr ended with status 23.
```

This is stronger than “the Bash job is broken.” It separates observed facts from root cause and tells the next engineer where to collect evidence.

### Step 2: preserve before reproducing

Preserve sanitized, access-controlled evidence:

- script revision or artifact digest;
- interpreter and dependency versions;
- normalized argument names, not secret values;
- working directory, effective UID, container or runner identity;
- start and end timestamps plus status;
- standard output and standard error as separate streams;
- candidate and previous artifact metadata;
- per-record operation IDs or redacted hashes;
- scheduler attempt and concurrency metadata.

Do not copy live secrets into an incident folder. Do not publish unredacted command traces. If a credential appears in logs or history, treat it as exposed: restrict access, revoke or rotate through the owning system, and investigate copies. Deleting one log line does not revoke a credential.

### Step 3: inspect source as a state transition graph

Do not read only top to bottom. Mark every point that:

- accepts input;
- expands into arguments;
- changes directory or environment;
- opens or truncates a file;
- starts a child or pipeline;
- makes an external side effect;
- records a receipt;
- retries;
- acquires or releases a lock;
- handles a signal;
- publishes or removes state;
- returns or exits.

Between any two mutation points, ask: “If the process disappears here, what durable truth remains?” That question reveals restart and rollback design. A script that cannot answer it is not safely resumable.

### Step 4: isolate the shell mechanism

Create a synthetic reproduction with no production data or endpoint. Replace a dangerous command with a probe that prints argument count and percent-q values. Replace an API with a deterministic fixture that can return permanent failure, transient failure, timeout-before-effect, timeout-after-effect, and duplicate-key responses. Use a private temporary root.

Vary one boundary at a time:

1. quoted versus unquoted parameter;
2. newline versus NUL framing;
3. pipeline with and without deliberate status capture;
4. final file versus staged candidate;
5. fresh operation ID versus stable logical ID;
6. one run versus two overlapping runs;
7. normal completion versus TERM at each transition.

A good reproduction predicts the failure before you run it. If it merely produces an error, it may not model the incident.

### Step 5: classify the immediate cause and root cause

The **immediate cause** is the mechanism that produced the observed failure: for example, unquoted command substitution split 18 records, or the pipeline selected a successful `tee` status.

The **root cause** is the deeper design or organizational condition whose correction prevents recurrence: for example, the interface had no record-framing contract, the publication gate trusted exit zero rather than validating record count, and CI lacked hostile-input and producer-failure tests. “An engineer forgot quotes” is rarely a sufficient root cause because another missing quote remains possible.

Contributing conditions can include weak review ownership, unpinned runtime, missing schema, retry defaults, poor redaction, or ambiguous exit codes. Name them without turning a post-incident review into blame.

### Step 6: choose the smallest safe move

Prefer a move tied to evidence:

| Evidence | Smallest safe move | Avoid |
|---|---|---|
| Record boundary destroyed before side effects | Stop batch, preserve manifest, build safe ingestion, reconcile by record ID | Blind replay |
| Producer failed; candidate is partial; prior final intact | Reject candidate, restore producer access, rerun into new candidate | Publishing partial bytes |
| Remote timeout after possible commit | Query by original operation ID | Retry with new ID |
| Two local writers contend | Return documented contention or wait boundedly | Delete lock path |
| Temporary root fails ownership or sentinel check | Refuse cleanup and investigate | `sudo rm -rf` |
| Secret entered logs | Contain access and rotate through owner | Merely add masking for future logs |
| Bash state machine is no longer reviewable | Freeze features, specify contract, migrate core incrementally | Unplanned big-bang rewrite during incident |

Mitigation restores or protects service. Remediation corrects the defect. Prevention changes the system so the class is detected or less damaging. Keep those phases distinct.

### Step 7: verify independently

Use a matrix:

```text
dimension          required evidence
normal success     real consumer accepts complete result
same run repeated  no duplicate external effect
producer failure   nonzero; prior final remains
permanent error    no retry
transient error    bounded attempts and elapsed time
unknown outcome    reconciliation before retry
concurrent run     one owner or safe versioned merge
TERM               stop boundary and resumable state
SIGKILL/startup     leftover detection and recovery
hostile records    exact count and byte-preserved argv
cleanup            exact state absent; foreign state untouched
```

No single test proves the design. Together, these tests make its invariants observable.

### Incident 1: false-green artifact publication

**Signal.** A release inventory job is green. Consumers report missing entries. The producer log contains a permission error after 222 of 240 records.

**Investigation.** The on-call engineer freezes automatic replay and captures the artifact digest, Bash version, invocation, separated streams, previous report, candidate report, and expected manifest count. An offline fixture with `quarter close` and `*.metadata` records shows that `for item in $(producer)` changes records. A producer that emits two lines then exits 23 piped into `tee` demonstrates visible partial output and default success from the last stage.

**Immediate cause.** Unquoted command substitution destroyed record boundaries, and pipeline status selection hid the producer failure.

**Root cause.** The publishing interface had no framing or completeness contract. The final path was written directly, success meant exit zero, and tests contained only simple names and successful producers.

**Mitigation.** Keep the previous known-good report published. Stop consumers from reading the partial candidate. Restore the producer's required read access through the owning configuration path after validating why it changed.

**Recovery.** Generate a new candidate using a structured manifest or lossless delimiter, capture the producer outcome, validate 240 unique expected operation IDs, and publish through a same-filesystem rename. Do not replay external side effects; reconcile receipts first.

**Verification.** The actual consumer parses 240 unique records, all expected IDs are present, the previous artifact survived injected failure, the pipeline returns nonzero when the producer exits 23, and a repeated successful generation produces the same semantic inventory.

**Prevention.** Add hostile record fixtures, producer-failure injection, staged publication, count and schema gates, separate stream capture, ShellCheck, and a runbook that begins with preserved state rather than retry.

### Incident 2: deployment timeout and duplicate effect

**Signal.** A deployment helper times out at 30 seconds. Its local receipt remains `pending`. The CI platform retries the job, and two deployment records appear remotely.

**Investigation.** The response deadline expired after the first server accepted operation X. The wrapper started the retry with operation Y because the ID was generated per process. A local PID file did not coordinate runners on different hosts. TERM interrupted cleanup, but that was not the duplication mechanism.

**Immediate cause.** A timeout with unknown outcome was classified as definite failure, and the retry used a new logical operation identity.

**Root cause.** The client-server contract lacked durable idempotency and reconciliation. CI retry policy was configured independently of operation semantics, and the script treated local marker state as authoritative remote state.

**Mitigation.** Pause automated retries and deployments for the affected scope. Query remote state and map both operations to the intended release. Keep the healthy committed version; compensate only if a reviewed rollback is safer than completion.

**Recovery.** Persist one operation ID with intent before attempting. Query that ID after timeout. If committed, write the receipt; if definitely rejected with a transient class, retry the same ID within budget; if unknown remains, escalate rather than duplicate.

**Verification.** Failure injection after server commit but before response produces one effect, resume reaches complete, concurrent runners do not create another logical ID, and central logs contain run and operation IDs without credentials.

**Prevention.** Add server-retained idempotency keys, authoritative status lookup, unknown-outcome metrics, a CI concurrency policy as defense in depth, retry-budget tests, and ownership documentation for client, CI, and API teams.

**Memory sentence:** the safest fix is the smallest state transition justified by preserved evidence, followed by an independent postcondition.

## Guided Ubuntu lab

The lab path is `book/labs/LES-0017-bash-automation`. It does not run a real unsafe script. A reviewed Bash fixture emits deterministic evidence for two automation incidents. The lifecycle wrapper guards every file it creates.

### Environment card

| Item | Contract |
|---|---|
| Platform | Ubuntu 24.04; WSL 2 Ubuntu 24.04 supported |
| Identity | Normal user; UID 0 refused before mutation |
| Time | 60-75 minutes guided; 90-110 minutes independent |
| CPU and memory | Short foreground Bash and core-utility processes; no load generation; under 32 MiB expected |
| Disk | Under 512 KiB in one private `/tmp` root and one descriptor |
| Network and ports | None; no socket, DNS, HTTP, container, cluster, or cloud call |
| Packages | Bash and Ubuntu base GNU utilities; no installation |
| Mutations | Exact allowlisted state under the registered lab root only |
| Cleanup | Named file removal and `rmdir`; no recursive delete |

Abort if root, a dependency is absent, `/tmp` is not a real root-owned sticky directory, a matching orphan exists, registered state fails validation, the fixture differs, or any command proposes an arbitrary path. Do not use sudo and do not manually remove a guessed directory.

### Preflight and setup

```bash
# [READ-ONLY]
bash lab.sh check

# [MUTATING / BOUNDED / OFFLINE]
bash lab.sh setup
bash lab.sh status
```

Expected clean preflight includes:

```text
lesson_id=LES-0017
environment=ready
privilege=normal-user
network=none
state=absent
next_command=bash lab.sh setup
```

Setup uses `mktemp -d` with a lesson prefix under `/tmp`, mode 0700, then records the exact root in a mode-0600 UID-scoped descriptor. It copies the model read-only for the owner and records a manifest. Repeated setup is idempotent only when every registered invariant remains valid.

### Establish a baseline

```bash
# [MUTATING / BOUNDED]
bash lab.sh run baseline
```

The baseline represents a healthy virtual automation run. Decode each field:

```text
input_records=6             count presented by the model
arguments_received=6        count after safe framing
producer_status=0           synthetic producer exit status
pipeline_status=0           status selected by safe orchestration
effects_committed=6         unique modeled side effects
candidate_records=6         records in staged output
publication=complete        candidate passed gate
operation_verified=true     modeled consumer postcondition
```

These are deterministic records, not host telemetry. They prove only what the fixture defines.

### Guided case: predict before derived evidence

Select the case and read raw input:

```bash
# [MUTATING / BOUNDED]
bash lab.sh inject guided

# [MUTATING / BOUNDED / OFFLINE] Records the raw-first marker.
bash lab.sh observe input
```

Before any other view, write:

```text
Exact failed operation:
Input framing contract:
Expected records and side effects:
Likely shell mechanism:
Alternative hypothesis:
Evidence that would separate them:
Unsafe action I will avoid:
```

The raw view contains input names and source behavior but no derived diagnosis or recovery. The lifecycle records that raw input was observed before allowing detailed views.

### Gather only discriminating views

```bash
# [READ-ONLY]
bash lab.sh observe expansion
bash lab.sh observe pipeline
bash lab.sh observe state
bash lab.sh observe retry
```

Do not read all views as a ritual. Each answers a question:

- `expansion`: expected logical records versus arguments received;
- `pipeline`: producer, consumer, selected, and per-stage statuses;
- `state`: prior final, candidate, committed effect, and operation receipt state;
- `retry`: attempt IDs, outcome classification, and duplicate potential.

State what each field proves and cannot prove. For example, `producer_status=23` proves the virtual producer returned 23; it does not prove why a real producer would fail. `candidate_records=4` proves modeled candidate incompleteness; it does not prove which production artifact is safe.

### Recover and verify the operation

After writing a diagnosis and smallest safe move:

```bash
# [MUTATING / BOUNDED / MODELED]
bash lab.sh recover
bash lab.sh verify-operation
bash lab.sh status
```

Recovery does not erase incident evidence. It records a case-specific modeled correction. Operation verification creates a separate receipt only when the recovered evidence satisfies the fixture's contract. Status should report preserved baseline, selected case, raw observation, recovery, and verification.

### Cleanup and cleanup proof

Move your reasoning transcript outside the registered lab root, then:

```bash
# [MUTATING / BOUNDED]
bash lab.sh cleanup

# [READ-ONLY]
bash lab.sh check
```

Cleanup validates descriptor, canonical root, basename, owner, mode, sentinel, manifest, fixed child allowlist, file types, link counts, and fixture bytes. It removes exact named artifacts, uses `rmdir` for empty directories and the root, removes the exact descriptor, then proves absence. Any mismatch is a refusal, not a reason to escalate privileges.

### Automated verifier

```bash
# [MUTATING / BOUNDED / OFFLINE]
bash verify.sh
```

The verifier exercises clean preflight, setup, idempotent setup, lifecycle prerequisites, baseline, guided and independent raw-before-derived gates, modeled recoveries, operation verification, argument refusal, fixture and unexpected-child refusal, cleanup, and final absence. Passing it proves those checks only. It does not prove your incident reasoning or production readiness.

### Independent case

Use ASM-0036 and its response template. Select `independent`, observe raw input, write the prediction, and do not open the fixture source. The case changes the constraint: two runs overlap and a timeout occurs after a modeled external effect. Explain why lock file existence, advisory lock ownership, remote operation identity, and authoritative reconciliation are four distinct pieces of evidence.

**Memory sentence:** the lab is complete only when the real modeled operation verifies and the guarded root is proven absent.

## Production transfer

### CI runners

A CI runner changes the environment:

```text
repository checkout -> generated workspace -> runner shell -> job image -> helper tools
        |                    |                 |             |
   revision/submodules   path/permissions   dialect/env   versions/certs
```

Make the job declare:

- exact container image digest or runner toolchain version;
- interpreter invocation, not an assumed default shell;
- repository working directory;
- required environment names and validation, with secrets supplied separately;
- artifact input and output paths;
- timeouts and cancellation behavior;
- concurrency policy and retry ownership;
- cache keys and whether caches are trusted input;
- status and artifact retention after failure.

Local success can differ because interactive startup files modify PATH, a workstation retains credentials, a filesystem ignores executable-bit changes, or GNU utilities differ. Reproduce CI with the same artifact and explicit environment rather than copying more workstation state into CI.

A CI retry is outside the script unless designed together. If the platform retries a whole job, every script step must either be idempotent, be guarded by durable receipts, or be excluded from automatic retry. A job concurrency group can reduce overlaps but does not replace remote idempotency; another client can still mutate the target.

### Containers

Inside a container, PID 1 has special signal and child-reaping responsibilities. An exec-form entrypoint can deliver TERM to the intended process; wrapping it in an extra shell without `exec` can leave signals at the wrapper. A container filesystem may be ephemeral or read-only, and `/tmp` can have a size limit.

A Bash entrypoint should:

- validate configuration before starting the service;
- avoid rendering secrets into command arguments or files that enter an image layer;
- use `exec -- program "${args[@]}"` when the service should replace the shell as PID 1;
- distinguish initialization from long-running supervision;
- handle TERM within the platform grace period;
- write durable state only to an explicitly mounted owner;
- avoid assuming a restart erases remote effects.

Do not build a process supervisor in Bash when a proper init or application lifecycle is needed. One script waiting on several children must reap them, propagate signals, and decide aggregate status correctly—a strong signal that another component should own the lifecycle.

### Kubernetes Jobs and controllers

Kubernetes makes retries and concurrency explicit but distributed. A Pod can restart; a Job can create another Pod; a controller reconciles desired state; an operator can apply the same manifest again. Local `/tmp` and `flock` state disappear with a Pod and are not shared across nodes.

For a Bash Job:

```text
Job intent
  -> Pod identity and service account
  -> container entrypoint and arguments
  -> API or data-store mutation with idempotency key
  -> durable receipt outside ephemeral rootfs
  -> Job condition plus real postcondition
```

Use a least-privilege service account. Prefer projected credential mechanisms and short-lived tokens. Do not print environment or service-account token content. Respect `terminationGracePeriodSeconds`, but design recovery for forced deletion and node loss. Use controller-level concurrency policy and durable leases only when their semantics match; a Lease is not a substitute for an application idempotency key.

Readiness and liveness probes are not appropriate ways to rerun a one-shot reconciliation. A failing liveness probe can create restart amplification. Emit a terminal status and use the Job/controller contract.

### Configuration management and infrastructure tooling

Bash often wraps Terraform, OpenTofu, Ansible, Helm, or cloud CLIs. Keep the tool's plan, state, lock, and apply semantics authoritative. A wrapper must not parse human-oriented plan text with `grep` to decide safety when a documented machine format exists. It must not auto-approve because a previous command exited zero.

For Terraform-like workflows:

```text
fmt -> validate -> init under reviewed network policy -> plan saved as artifact
    -> human/policy review -> apply exact reviewed plan -> verify real resources
```

The wrapper owns orchestration and evidence. The IaC tool owns state and provider operations. Remote backend locking does not guarantee application-level zero downtime. A wrapper retry after unknown provider outcome must reconcile through tool state and provider evidence.

### APIs and remote shells

Prefer a local API client receiving an argv array and structured payload file over constructing command strings. Never embed secrets in a URL. Capture response body and status separately within size limits, redact before logging, and distinguish transport failure from HTTP or application failure.

Remote shell execution adds another parser. This:

```bash
ssh host "command $value"
```

can involve local expansion, SSH argument handling, and remote-shell parsing. One layer of quotes rarely preserves arbitrary hostile data through both. Prefer copying a reviewed script and structured input, invoking a fixed remote command with constrained arguments, or using an API/configuration-management transport. The chapter lab intentionally avoids remote execution.

### Data and machine-learning platforms

Airflow, Spark, Flink, and data pipelines often launch shell tasks. The same boundaries become expensive at scale: a missing record can silently alter a partition, immediate retries can overload a catalog, and logs can expose data. Use workflow-engine operation IDs, partition-level receipts, bounded retry, structured manifests, and durable checksums. Bash can prepare an invocation, but data parsing and distributed checkpointing belong to the platform or typed application.

### Private and public cloud

Cloud CLIs are API clients. A zero exit can mean the request was accepted, not that an asynchronous resource reached desired state. A timeout can hide a committed operation. Region, subscription or account, project, role, and endpoint are part of the target boundary.

Before a mutating call, log sanitized identity and scope, not credential material. Use a plan or describe phase when available, stable client request IDs, service-native waiters with bounded deadlines, and an authoritative read after mutation. Online cloud use is outside this core lab and requires separate authorization and cost controls.

**Memory sentence:** when automation moves into CI or Kubernetes, local process safety remains necessary but durable identity and distributed reconciliation become mandatory.

## Reliability, security, observability, capacity, and cost

### Reliability

Reliability is not “the script usually exits zero.” Define service-like objectives for important automation:

- correctness: fraction of intended records reaching one verified terminal outcome;
- timeliness: age of oldest unreconciled operation;
- availability: fraction of authorized runs that reach verified completion within deadline;
- integrity: zero unaccounted duplicate or missing effects;
- recoverability: interrupted runs resume or reconcile within a target time;
- cleanup: no stale private state beyond an allowed window.

A script may be available but incorrect. A fast wrong deployment is worse than a slow refused one. Alert on stuck unknown outcomes, missing receipts, publication age, or user impact rather than every transient attempt.

Use idempotency at the state owner. Make partial progress visible. Keep previous known-good output. Bound every wait. Treat cleanup failure as evidence. Test interruption between durable transitions. Version manifest formats so old and new script versions can recover each other's state during rollout.

### Security

Threat-model four input families:

1. command-line and environment values;
2. filesystem names, contents, links, owners, and permissions;
3. external command output and API responses;
4. repository code, dependencies, images, and generated artifacts.

Core controls:

- never `eval` untrusted or variable data;
- use arrays and quote every value at the argv boundary;
- use `--` where a utility documents it;
- canonicalize and authorize paths, not just sanitize characters;
- create temporary state exclusively with restrictive permissions;
- validate file type, owner, mode, links, parent, and sentinel before cleanup;
- avoid following symlinks across a mutation boundary;
- run with least privilege and refuse root when not needed;
- pin and verify important tool or image versions;
- never download and execute code in one pipeline;
- separate secrets from arguments, traces, artifacts, and ordinary logs.

Shell injection is not limited to semicolons. Command substitution, option injection, wildcard expansion, response-file syntax supported by a called tool, remote-shell parsing, and config-language interpolation can all reinterpret data. Validate at every interpreter boundary.

### Observability

A useful structured diagnostic line might contain:

```text
timestamp=2026-08-02T10:14:23Z level=error run_id=R1842
operation_id=release-1842 step=publish attempt=2 elapsed_ms=30124
result=unknown reason=deadline_exceeded retryable=false
```

Include:

- version or artifact digest;
- run and stable operation IDs;
- step name and attempt number;
- monotonic duration for intervals when available;
- normalized result class and status;
- counts: expected, started, committed, failed, unknown;
- lock wait and contention;
- candidate and publication version;
- cleanup outcome.

Do not include raw tokens, credentials, authorization headers, signed URLs, private keys, unbounded payloads, or unreviewed filenames. Central logging changes the audience and retention of every line. Redaction should happen before emission, not only in a downstream dashboard.

Standard output can be a stable machine contract such as JSON or one exact value. Standard error can carry diagnostics. A result artifact can hold larger structured evidence. Decide which channel the caller parses and never mix human progress lines into it.

### Capacity and performance

Shell process startup is cheap at small scale and expensive in tight loops. A loop spawning `grep`, `cut`, `sed`, and `awk` per record can create thousands of processes. Prefer one tool invocation that consumes the dataset when it remains understandable, or move data processing into a language with in-process structures.

Estimate:

```text
process_starts = records * external_commands_per_record
maximum_parallel_effects = workers * effects_per_worker
retry_load = initial_attempts + retry_attempts
memory ~= input arrays + captured stdout + child working sets
disk ~= candidates + previous versions + logs + retry receipts
```

Command substitution stores output in memory and removes trailing newlines; it is unsuitable for large streams. Pipelines stream data but complicate stage failure and partial effects. Arrays preserve records but retain them in shell memory. Choose deliberately.

Concurrency can improve throughput and destroy dependencies. Bound worker count, propagate every child status, cancel safely, preserve per-item receipts, and implement backpressure. `wait` without a clear PID-to-operation map can lose attribution. `xargs -P` or GNU Parallel has its own record and failure contract; do not add parallelism until sequential idempotency and reconciliation are proven.

### Cost

Local Bash itself is not the main cost. Automation triggers compute, API requests, storage, network egress, log ingestion, and engineer time. Retry storms multiply each. Unbounded debug output can make logging surprisingly expensive and retain sensitive data.

Measure:

- attempts per successful logical operation;
- external API calls and rate-limit responses;
- runner minutes and queue time;
- artifact and log bytes retained;
- stale resources after failed cleanup;
- engineer hours spent reconciling ambiguous outcomes.

Cost optimization must preserve correctness. Removing receipts or reducing retention below the recovery window can save storage and make an incident far more expensive. Prefer eliminating duplicate work and noisy logs over removing essential evidence.

### Operability and human factors

The next on-call engineer needs:

- `--help` with examples and risk class;
- `--version` tied to source or artifact;
- a dry-run whose exact limits are documented;
- stable exit codes and result schema;
- a status or reconcile subcommand;
- bounded timeouts and visible progress without secrets;
- a runbook for unknown outcomes and cleanup refusal;
- rollback that addresses external state, not only code version.

Make the safe path the easy path. If operators must memorize a six-line quoting ritual or manually delete state after every interruption, the interface is unfinished.

**Memory sentence:** production-grade shell automation is a small service interface with reliability, security, observability, capacity, and cost consequences.

## Traps and prevention

### Trap: “strict mode makes Bash safe”

**Why it fails:** options change selected error behavior but do not validate input, preserve record framing, make side effects atomic, provide locks, classify retry, or roll back state.

**Prevention:** keep the options when appropriate, then add explicit validation, documented expected-failure branches, state transition tests, and independent verification.

### Trap: unquoted expansion as a list

**Why it fails:** a string is not an array. Word splitting and pathname expansion reinterpret its bytes.

**Prevention:** keep separate values in arrays, expand with `"${array[@]}"`, and choose a lossless input delimiter. ShellCheck warnings are a gate, not the complete proof.

### Trap: `for x in $(command)`

**Why it fails:** command output is converted to shell words before the loop. Whitespace, glob characters, empty records, and trailing newlines cannot be trusted as record boundaries.

**Prevention:** use a declared line protocol with `IFS= read -r`, NUL framing for arbitrary paths, or structured parsing. Capture producer failure separately.

### Trap: testing a command with `[ $(command) = value ]`

**Why it fails:** empty or multiword output can change the test's arguments, wildcard content can expand, and the command's own status is discarded.

**Prevention:** capture output and status in an explicit branch, quote the value, validate its format, then compare with `[[ $value == expected ]]` when Bash is the dialect.

### Trap: parsing `ls`

**Why it fails:** `ls` formats output for display, escapes or quotes depending on options and environment, and newline is legal inside a filename.

**Prevention:** operate on pathnames through direct glob arrays when scope is known, or use NUL-aware discovery and consumption. Always validate the mutation root.

### Trap: a leading dash becomes an option

**Why it fails:** quoting preserves the string `-rf`; it does not tell the utility it is an operand.

**Prevention:** use `--` when documented, prefer exact paths containing a slash, and validate the target. Do not assume every utility supports `--`; check its contract.

### Trap: pipeline output means pipeline success

**Why it fails:** upstream failure can coexist with useful partial output, and default status normally belongs to the last stage.

**Prevention:** use `pipefail` deliberately, capture necessary stage statuses immediately, isolate candidate output, and validate before publication. Test early-closing consumers and SIGPIPE.

### Trap: `|| true` makes cleanup robust

**Why it fails:** it converts all failures into success and destroys the distinction between already absent, permission denied, wrong owner, and unsafe path.

**Prevention:** allow only the specific expected outcome, log it, and fail closed on invariant violations. Make cleanup idempotent through checks, not status erasure.

### Trap: predictable `/tmp` paths

**Why it fails:** another actor can create a file or symlink first, permissions may be broad, and stale state can be mistaken for this invocation.

**Prevention:** restrictive `umask`, secure `mktemp`, exact parent and prefix, immutable registered root, owner/mode/type checks, sentinel, allowlist, and `rmdir` cleanup.

### Trap: trap means guaranteed cleanup

**Why it fails:** SIGKILL, host loss, kernel failure, runtime bugs, and some abrupt exits bypass handler execution. Trap code can also fail or reenter.

**Prevention:** make cleanup idempotent and validated, preserve durable intent, detect stale state at startup, and test TERM, INT, ordinary errors, and simulated abrupt loss.

### Trap: PID file means lock

**Why it fails:** a file can outlive the process, PIDs are reused, namespaces show different identities, and two writers can race while creating or checking it.

**Prevention:** use a real coordination primitive with documented filesystem or service semantics. A PID record can aid evidence only after process identity is revalidated.

### Trap: delete the lock file to unblock

**Why it fails:** a holder can retain a lock on the old inode while new contenders lock a newly created inode, producing two critical sections.

**Prevention:** diagnose the holder through authorized evidence, let descriptor lifetime release the advisory lock, and use bounded lease semantics when crash expiration is required.

### Trap: retry every nonzero status

**Why it fails:** validation and authorization errors persist, immediate retries amplify load, and unknown mutation outcomes can duplicate effects.

**Prevention:** classify errors, require idempotency, reconcile unknown outcomes, cap attempts and elapsed time, apply backoff with jitter, and expose retry metrics.

### Trap: environment variables are trusted configuration

**Why it fails:** names can be absent, inherited, stale, overridden, or secret-bearing; values can contain hostile bytes; exported variables reach children.

**Prevention:** run with a minimal explicit environment where practical, validate names and values, export only what children require, and never dump the environment to logs.

### Trap: xtrace is observability

**Why it fails:** it prints expanded commands rather than domain outcomes and can expose secrets. High-volume traces are hard to search and expensive to retain.

**Prevention:** emit structured sanitized events with run, operation, step, attempt, duration, and result. Use controlled trace only in a synthetic or protected diagnosis.

### Trap: sourced configuration is data

**Why it fails:** `source config.env` executes shell code with the script's authority. A value file becomes a program.

**Prevention:** use a non-executable configuration format and a real parser, or enforce an extremely narrow parser that rejects everything outside the format. Protect file ownership and review changes.

### Trap: atomic rename means durable transaction

**Why it fails:** old-or-new name visibility on one filesystem does not synchronize data to stable storage, coordinate a database or API, or span filesystems.

**Prevention:** state the exact atomicity and durability requirement, keep candidate on the same filesystem, validate before rename, and use the external owner's transaction protocol for external state.

### Trap: a successful dry-run authorizes apply

**Why it fails:** state can change between plan and apply, dry-run may omit provider behavior, and credentials or target scope may differ.

**Prevention:** bind apply to the reviewed immutable plan or intent when the tool supports it, revalidate identity and scope, check drift, define approval, and verify the real outcome.

### Trap: shell portability by wish

**Why it fails:** Bash syntax under `/bin/sh`, GNU flags on another userland, different `sed` or `stat`, filesystem semantics, and locale all alter behavior.

**Prevention:** declare the dialect and platforms, run parser/static/tests for each, pin CI, or simplify the interface. Do not weaken safe arrays into strings to claim portability.

### Trap: Bash must be used forever because it already exists

**Why it fails:** incremental features can turn orchestration into an opaque protocol client and concurrent state machine. Fear of migration raises incident and change cost.

**Prevention:** measure complexity and defect signals, freeze the CLI contract, add characterization tests, move one state-owning component behind the same interface, compare behavior, canary, and retain rollback.

**Memory sentence:** prevention lives at the failed boundary—data contract, status contract, state protocol, coordination, or verification—not in a bigger blanket of shell options.

## Memory card and retrieval

### The BOUNDARY card

When a shell automation incident begins, remember **BOUNDARY**:

```text
B  Baseline the interpreter, identity, directory, version, and exact operation.
O  Observe argv, streams, statuses, state, and postcondition separately.
U  Understand parsing and expansion before blaming the called utility.
N  Name each state owner: shell, process, filesystem, scheduler, or remote API.
D  Define record framing, exit codes, deadlines, and cleanup scope.
A  Attempt one bounded idempotent move only after classification.
R  Reconcile unknown outcomes before retry or rollback.
Y  Yield evidence: verify the real outcome and prove cleanup.
```

### One-screen production checklist

```text
RUNTIME
[ ] Bash or POSIX dialect declared and tested
[ ] required commands and versions checked before execution
[ ] normal least-privilege identity and exact cwd known

INPUT
[ ] CLI rejects unknown, missing, repeated, and extra arguments
[ ] enums, numbers, units, paths, owners, types, and sizes validated
[ ] values never become code; no eval
[ ] record framing is explicit; arbitrary paths are NUL-safe
[ ] arrays expanded as "${array[@]}"; utility option boundary handled

FAILURE
[ ] stdout, stderr, and exit status have separate contracts
[ ] pipeline stages and partial output are handled
[ ] strict-mode behavior is tested in actual grammar contexts
[ ] every blocking operation has a deadline
[ ] permanent, transient, conflict, and unknown outcomes are distinct

STATE
[ ] intent and stable operation ID recorded before risky effect
[ ] unknown mutations reconcile before retry
[ ] candidate output validates before atomic local publication
[ ] local lock scope is explicit; distributed ownership is separate
[ ] retry is bounded, jittered, and idempotent

RECOVERY
[ ] TERM/INT stop path tested; SIGKILL/startup recovery designed
[ ] cleanup validates exact owner, parent, prefix, sentinel, and children
[ ] rollback addresses committed external state
[ ] real consumer or state owner verifies success

EVIDENCE
[ ] bash -n, ShellCheck, unit, black-box, hostile-input tests
[ ] failure injection, repeated-run, concurrent-run, resume tests
[ ] logs include run/operation/step/status/duration without secrets
```

### Retrieval questions—attempt before revealing answers

1. Why can `"$value"` be necessary and still insufficient for safety?
2. What exactly does `pipefail` change, and what does it leave unchanged?
3. Why is `set -e` not an exception system or transaction?
4. What is the difference among a lock file, an advisory lock, a lease, and an idempotency key?
5. A remote mutation times out. What are the three outcome classes, and which one is directly retryable?
6. Why should a temporary candidate be created in the final file's directory before rename?
7. Which signals can a trap not make safe, and how does the design compensate?

Stop here long enough to answer in your own words. The complete explanations are in the next section. Reading the answer feels familiar; producing the boundary and evidence from memory demonstrates retrieval.

### Spaced review

- **After one day:** draw the parser-to-status diagram and explain one quote failure without commands.
- **After three days:** reproduce the synthetic pipeline failure, then explain partial output and status as separate facts.
- **After seven days:** design a safe staged publisher and name its crash boundaries.
- **After fourteen days:** solve ASM-0036 without viewing earlier notes; compare the operation-state diagram.
- **After thirty days:** review a real nonproduction script and identify its data, state, failure, time, secret, and rollback contracts.

Do not mark mastery from reading or verifier success. Durable evidence requires independent work, explanation, later recall, and transfer to a changed constraint.

## Complete answers

### 1. Why can quoting be necessary and insufficient?

**Direct answer.** Double-quoting a parameter normally preserves its expanded value as one argument, including an empty value, and suppresses word splitting and pathname expansion. It does not validate authorization, stop a leading dash from being interpreted as an option, encode the value for JSON or SQL, prevent the called program from interpreting it as a pattern, or make remote-shell parsing safe.

**Foundation.** Bash and the called utility own different layers. In `rm -- "$path"`, the quotes tell Bash to pass one argument containing the exact path value. `--` tells GNU `rm` that following arguments are operands, not options. A separate validator must prove the path is inside an approved root, has the expected type and owner, and is authorized for removal. Each control answers a different question.

**Senior production answer.** I model each interpreter boundary separately. Shell quoting preserves argv boundaries for one shell expansion. Then I use an array to avoid re-parsing, the utility's option terminator when documented, a canonical allowlisted target with descriptor or ownership checks, and the receiving language's data API. For JSON I serialize with a real JSON implementation; for SQL I use parameters; for SSH I avoid concatenating remote programs. I test hostile values and verify the actual side effect scope.

**Weak answer.** “Put double quotes around every variable and injection is solved.”

**Why weak.** Some expansions deliberately represent multiple arguments; pattern and regex contexts have different rules; values can still be unauthorized or secret; and downstream interpreters can reinterpret the preserved string.

### 2. What does `pipefail` change and leave unchanged?

**Direct answer.** In Bash, `pipefail` makes a pipeline return failure when one or more stages fail, selecting the rightmost failing stage's status instead of normally using only the last stage. It does not prevent partial output, undo side effects, serialize stages, preserve every stage status after later commands, or decide which failures are expected.

**Foundation.** A producer and consumer run concurrently. A producer can write half a report and fail; the consumer can successfully write those bytes. `pipefail` exposes a nonzero pipeline status, but the partial file remains. `PIPESTATUS` can show individual stage statuses immediately after the pipeline. A candidate-validation and publication rule is still required.

**Senior production answer.** I enable `pipefail` for Bash automation where upstream failure must propagate, capture `$?` and `PIPESTATUS` before another command, and design downstream partial-output handling. I test intentional early termination because SIGPIPE from `head`-like consumers can produce an expected upstream nonzero. For complex pipelines, I split stages into named files or processes so status, validation, resource bounds, and cleanup are explicit.

**Weak answer.** “`pipefail` guarantees the entire pipeline succeeded or rolled back.”

**Why weak.** Status aggregation and transactional state are unrelated. Each stage may already have changed files or remote systems.

### 3. Why is `set -e` not an exception system or transaction?

**Direct answer.** `errexit` asks Bash to exit after certain unhandled nonzero statuses, subject to grammar-context rules. It neither runs around every failure like a language exception nor reverses effects completed before exit.

**Foundation.** Nonzero status is also normal control flow: `grep` can report no match, `test` can be false, and an `if` condition branches on status. Bash suppresses or changes `errexit` behavior in documented contexts so those constructs work. A command can create a resource and then fail; exiting the shell leaves that resource unless explicit recovery owns it.

**Senior production answer.** I use `set -Eeuo pipefail` as a baseline defect detector in scripts designed for it, but every expected status is captured in `if` or an explicit assignment branch. Functions have documented statuses; candidates are not published until validated; external effects have operation IDs and reconciliation; cleanup is idempotent; and failure injection checks each commit point. I never infer transactionality from process termination.

**Weak answer.** “Turn on strict mode and remove all `if` checks because Bash stops on errors.”

**Why weak.** It misclassifies expected nonzero outcomes, ignores grammar exceptions, loses reason codes, and leaves partial state unhandled.

### 4. Lock file, advisory lock, lease, and idempotency key

**Direct answer.** A lock file is merely a filesystem object unless a protocol gives it meaning. An advisory lock is kernel/filesystem coordination honored by cooperating processes, often tied to an open descriptor. A lease is ownership that expires or must be renewed under a clock and authority. An idempotency key identifies one logical operation so repeated attempts can be deduplicated by the state owner.

**Foundation.** Creating `/tmp/job.lock` does not prove a process is alive or uniquely owns work. `flock` asks the local system to grant one cooperating holder a lock. A distributed lease can coordinate hosts but must handle expiry and fencing. An API idempotency key prevents two accepted attempts from becoming two logical effects. These mechanisms are complementary.

**Senior production answer.** I pick the primitive at the state boundary. `flock` can protect a local manifest on a tested filesystem. A Kubernetes Lease or database row with fencing can coordinate distributed controllers. The remote mutation still uses a stable server-recognized operation ID, because lock loss, client crash, or response loss can leave a committed effect. After acquiring any lock or lease, I reread state; after unknown mutation, I reconcile by operation key.

**Weak answer.** “Write the PID into a file and delete it if the process seems stale.”

**Why weak.** PIDs are reused and namespaced, file creation can race, deletion can split lock inodes, and none of it deduplicates a remote request.

### 5. Timeout outcome classes and retry

**Direct answer.** A mutation attempt can be definitely committed, definitely rejected, or unknown. A definitely rejected outcome is directly retryable only when the error is classified transient, the operation is idempotent, and budgets allow. A committed outcome is verified, not retried. An unknown outcome is reconciled before retry.

**Foundation.** A timeout is a client clock event. The request may never have left, may be in flight, or may have committed while the response was lost. Without a stable operation identity and status query, the client cannot distinguish them.

**Senior production answer.** I persist intent and key before send, set connect/request/overall deadlines, and classify protocol and transport results. On timeout, I query by the same key. If committed, I record receipt; if authoritatively absent or rejected with a reviewed transient reason, I retry the same key using capped exponential backoff and jitter; if still unknown, I stop admission or escalate. Metrics track unknown-outcome age and retries per logical operation.

**Weak answer.** “Timeout means failure, so retry three times with a new request.”

**Why weak.** It converts response uncertainty into duplicate effects and can amplify an unhealthy dependency.

### 6. Why create the candidate beside the final file?

**Direct answer.** A candidate on the same filesystem can be validated and then renamed over the final name with atomic old-or-new name visibility. A move across filesystems may become copy plus delete, exposing partial bytes and different failure points.

**Foundation.** Readers should see the prior complete report until the next complete report is ready. Writing directly to the final path truncates early. Writing elsewhere and copying can expose progress. Same-directory secure creation also makes parent, ownership, and permissions easier to validate under one boundary.

**Senior production answer.** I securely create in the destination directory with restrictive mode, write and close with checked status, validate schema/count/checksum, preserve the prior version, rename within the filesystem, and reopen through the consumer path. If crash durability matters, I add the filesystem-specific data and directory synchronization contract. I do not claim local rename coordinates database or API state.

**Weak answer.** “`mv` is always atomic, so put the temp file anywhere.”

**Why weak.** Atomicity depends on the filesystem boundary and addresses namespace visibility, not every durability or distributed transaction requirement.

### 7. Untrappable failure and compensation

**Direct answer.** SIGKILL cannot be trapped, and power loss, kernel failure, runtime termination, or machine disappearance can prevent all cleanup code. Design startup detection, durable intent and receipts, secure stale-state validation, idempotent cleanup, and reconciliation rather than relying on a guaranteed trap.

**Foundation.** TERM and INT normally give a process a chance to respond; KILL forcibly ends it. Even a correct handler may be interrupted again or fail. Therefore temporary state carries an owner and sentinel, external effects carry an operation ID, and the next invocation can decide what is safe.

**Senior production answer.** Signal handlers stop admission and persist a resumable boundary within a deadline; EXIT reports and performs only validated idempotent cleanup. The manifest records state transitions before and after effects. On startup, the program refuses ambiguous foreign state, reacquires coordination, rereads authoritative state, reconciles unknown operations, and then resumes or compensates. Tests terminate at every transition, including a SIGKILL-like abrupt process loss.

**Weak answer.** “Trap EXIT and run `rm -rf` so the directory always disappears.”

**Why weak.** EXIT is not guaranteed, recursive deletion can cross scope, and disappearance of local files can destroy the only evidence needed to reconcile an external effect.

### The integrated answer

A production-grade Bash program is not defined by `set -Eeuo pipefail`. It is defined by visible contracts:

```text
data remains data
  + status remains attributable
  + state transitions remain reconstructable
  + time and concurrency remain bounded
  + secrets remain outside evidence
  + unknown outcomes reconcile
  + publication and cleanup are verified
```

That combination makes a small shell orchestrator boring in the best way: another engineer can predict how it behaves before touching a real system.

## Product-company interview

### Scenario 1: false success in a pipeline

**Question.** A Bash job runs `generate | gzip >artifact.gz` and exits zero, but the archive is incomplete. How do you debug and redesign it?

**Model answer.** I preserve the exact script, Bash version, stage diagnostics, archive metadata, previous artifact, and expected source manifest, then stop publication and retries. By default the pipeline status normally represents `gzip`; an upstream `generate` failure can be hidden while `gzip` successfully closes a partial archive. I reproduce with a synthetic producer that emits data then exits nonzero, capture `PIPESTATUS` immediately, and test with `pipefail`. The redesign writes a private candidate, captures all required stage outcomes, validates archive integrity and expected manifest, then renames into the final path on the same filesystem. A prior final remains until verification. I add producer-failure, storage-failure, SIGPIPE, and partial-candidate tests. `pipefail` is evidence propagation, not rollback.

**Weak-answer warning signs.** “Just add `set -e`,” “rerun it,” or “if gzip exits zero the archive is valid.” These ignore upstream status, partial output, publication, and expected-record validation.

**Level signal.** A junior identifies `pipefail`; a mid-level captures stage status and validates output; a senior designs publication, recovery, observability, and failure tests while protecting prior state.

### Scenario 2: safe filename processing

**Question.** Delete only `.tmp` files under one approved cache root, including names with spaces, newlines, wildcard characters, and leading dashes. What design do you review before any deletion?

**Model answer.** First I challenge whether deletion is necessary and establish ownership, retention, mount, and rollback boundaries. Discovery and mutation must share a narrow root. I do not parse `ls`, use `for x in $(find ...)`, or pipe a broad discovery set into deletion. I canonicalize and validate the cache root, reject root/symlink/foreign-owner surprises, and use a tool expression scoped beneath that root with exact type, name, age, and mount policy. I preview the exact candidates using a NUL-safe record protocol, count and review them, then use a separately reviewed mutation expression no broader than the preview. Downstream arguments use `--`. I consider races: a path can change after discovery, so descriptor-relative or single-tool traversal may be safer than a two-pass loop. I record counts and prove intended absence without claiming other files are untouched merely from status zero. For a learning lab I use a disposable private fixture; I do not invite host cleanup.

**Weak-answer warning signs.** `rm -rf "$dir"/*.tmp`, parsing `ls`, using sudo, or assuming quotes handle leading options and authorization.

**Level signal.** Senior answers include time-of-check/time-of-use, mount boundaries, exact ownership, preview-to-delete equivalence, and recovery limitations.

### Scenario 3: retry and idempotency

**Question.** A deployment API call times out after 30 seconds. CI retries the job. How do you prevent duplicate deployment effects?

**Model answer.** I do not equate timeout with rejection. Before the first call, the client persists a stable logical operation ID with desired intent. Every attempt uses that ID, and the server stores or derives a deduplication result for an adequate window. On timeout, the client queries authoritative state by that ID or resource generation before retrying. It distinguishes committed, definitely rejected, and unknown. Only a transient definite rejection is retried, with capped attempts, elapsed-time budget, exponential backoff, jitter, and respect for server guidance. CI whole-job retry uses the same durable intent and must not generate a fresh ID. A local lock or CI concurrency group reduces overlap but does not replace server-side idempotency. Verification reads the deployed version and user health, not merely the request receipt.

**Weak-answer warning signs.** “Retry three times,” “use a random UUID on every call,” or “create a lock file in `/tmp`.” These fail at unknown outcome and distributed ownership.

**Level signal.** Staff-level answers define retention, canonical identity, reconciliation, overload control, and ownership across client, scheduler, and API teams.

### Scenario 4: signal-safe Kubernetes entrypoint

**Question.** A service does not terminate cleanly in Kubernetes because a Bash wrapper remains PID 1. What do you change?

**Model answer.** I inspect the image ENTRYPOINT/CMD forms, process tree, signal delivery, grace period, child behavior, and shutdown requirement. If the script only validates configuration then starts one service, it should `exec` the service with an argv array so the service replaces Bash and receives TERM directly. If initialization creates external state, it needs idempotent receipts and reconciliation independent of process lifetime. If the wrapper truly supervises children, it must forward signals, reap every child, aggregate status, stop admission, and respect the grace deadline; a small init or proper supervisor is usually better. Secrets stay out of argv and xtrace. I test TERM, readiness removal, in-flight drain, deadline escalation, restart, and actual service availability. I do not add an infinite sleep or broaden the grace period without evidence.

**Weak-answer warning signs.** “Trap TERM and kill -9 everything,” “Kubernetes will handle it,” or “add `tail -f /dev/null`.” These hide lifecycle rather than fix ownership.

**Level signal.** Strong answers connect PID 1, exec form, signal and child ownership, graceful drain, forced-loss recovery, and controller behavior.

### Scenario 5: when to migrate from Bash

**Question.** A 900-line Bash deployment tool works but is hard to change. Do you rewrite it?

**Model answer.** Line count alone is not the decision. I inventory blast radius, defects, change lead time, data complexity, subprocess count, concurrency, protocol logic, state transitions, security exposure, tests, and consumers of its CLI. I first freeze and document the observable interface, add characterization tests for arguments, streams, statuses, files, and remote calls, and separate pure decisions from effects. If the core is now parsing rich structured data, managing concurrent remote operations, maintaining durable state, or duplicating libraries, I migrate incrementally behind the same CLI or an explicit versioned interface. A typed core owns data and protocol logic; Bash may remain a thin launcher. Canary both implementations against synthetic or read-only state, compare decisions, preserve manifest compatibility, and retain rollback. I do not big-bang rewrite during an incident or keep Bash solely because migration is uncomfortable.

**Weak-answer warning signs.** “Bash is always bad after 100 lines” or “never rewrite working code.” Both ignore measured risk and migration safety.

**Level signal.** A senior balances operational risk, compatibility, incremental seams, rollout evidence, and organizational ownership rather than arguing from language preference.

### Answered follow-ups

**What tests would you require in CI?** `bash -n`; ShellCheck with pinned or recorded version and agreed severity; pure function tests; black-box CLI tests for argv, streams, files, and statuses; hostile input; missing dependencies; read-only paths; producer and consumer failures; timeout before and after effect; duplicate operation; concurrent runs; TERM and abrupt-loss recovery; prior-artifact preservation; cleanup refusal and proof; secret-canary absence from logs.

**How do you keep logs useful without exposing secrets?** Emit explicit fields from allowlisted nonsecret values, separate result from diagnostics, hash or tokenize sensitive identifiers when correlation requires it, cap payloads, disable xtrace around secrets, never put credentials in argv or URLs, sanitize error bodies, restrict artifact access and retention, and test with fake secret-shaped canaries.

**What is a safe dry-run?** A mode whose exact side effects are documented and tested. It should validate and calculate decisions without applying target mutations, but may still read state, authenticate, acquire a local lock, or write a private plan if declared. Its output is not authorization for a later apply unless identity, target, state version, and immutable plan binding are revalidated.

**How do you test a race deterministically?** Add controlled synchronization points in the fixture: process A acquires or reads, signals a barrier, process B attempts or changes state, then A continues. Assert one winner, reread after acquisition, stable version rules, and final invariant. Repeating a timing-dependent test many times is useful stress evidence but not a deterministic proof.

**What does rollback mean for an accepted API mutation?** Reverting the Bash file stops future behavior but does not undo the remote effect. Query actual state by operation ID, decide whether completion is safer, and invoke a documented compensating or rollback operation when supported. Preserve audit evidence and verify the resulting user outcome.

## Independent transfer and rubric

### Assignment

Use ASM-0036 and `ASM-0036-response-template.md`. Work only in `book/labs/LES-0017-bash-automation` as a normal user. The independent fixture presents overlapping runs and an ambiguous timeout after an effect. The answer is intentionally absent from the assessment record.

Sequence:

```bash
bash lab.sh check
bash lab.sh setup
bash lab.sh run baseline
bash lab.sh inject independent
bash lab.sh observe input
# Write prediction now, before any derived view.
bash lab.sh observe expansion
bash lab.sh observe pipeline
bash lab.sh observe state
bash lab.sh observe retry
# Explain the safe move before invoking it.
bash lab.sh recover
bash lab.sh verify-operation
bash lab.sh cleanup
bash lab.sh check
bash verify.sh
```

Do not inspect the fixture implementation, change model files, run as root, install anything, start a service, contact a network, or delete a path manually. A guard refusal is evidence; stop and report it.

### Required deliverable

Your submission contains:

1. prediction written after raw input and before derived evidence;
2. exact command transcript and relevant statuses;
3. state and control-flow diagrams with text alternatives;
4. evidence table labeled observation, fact, calculation, inference, hypothesis, unknown;
5. immediate cause, contributing conditions, root cause, and alternative hypothesis;
6. smallest safe mitigation, reconciliation, recovery, rollback boundary, and cleanup proof;
7. implementation outline covering CLI, quoting, framing, status, trap, temp state, idempotency, retry, locking, logs, and secrets;
8. verification matrix including repeated, concurrent, interrupted, hostile-input, and failure paths;
9. CI and Kubernetes transfer with changed boundaries;
10. concise incident update and prevention owners.

### Scoring rubric: 50 points

| Area | Points | Observable evidence |
|---|---:|---|
| Prediction discipline and model | 10 | Raw-first timestamped prediction; exact operation; state owners; alternatives; discriminating evidence |
| Shell mechanism | 10 | Correct parse/expansion/framing, pipeline/status, strict-mode, function/array, trap, and exit-policy explanation |
| Safe state and recovery | 10 | Stable operation identity; unknown-outcome reconciliation; local lock scope; idempotency; bounded retry; rollback boundary |
| Verification and lab safety | 10 | Real modeled outcome; repeat/concurrency/interruption/failure tests; guard refusals; final absence; no prohibited action |
| Production transfer and communication | 10 | CI/Kubernetes identity, durable state, secrets, logs, controller retries; clear incident and prevention communication |

Score bands:

- **45-50:** advanced transfer candidate; no unsafe action; causal mechanism and changed boundaries are precise.
- **38-44:** strong but one important gap needs correction and retest.
- **30-37:** guided understanding; missing evidence or unsafe assumption blocks advancement.
- **Below 30:** foundation gaps; revisit the exact failed boundary before another attempt.

Any use of root, network, package installation, fixture modification, blind replay, arbitrary recursive deletion, unbounded retry, `eval`, or fabricated evidence is an automatic safety-gate failure regardless of score. It is feedback, not permanent judgment; remediate and repeat in a fresh guarded state.

### Mastery boundary

Passing the verifier does not award mastery. Publishing this lesson does not award mastery. A reviewer must examine the independent evidence, ask the learner to explain the parser and state diagrams without notes, and later test a changed unfamiliar case. The progress ledger changes only after that review.

## References and review

### Primary references

1. **REF-0089 — GNU Bash Reference Manual.** The language authority for shell operation, quoting, expansion order, redirection, pipelines, functions, arrays, options, traps, and exit status. The online manual currently documents Bash 5.3; Ubuntu 24.04 commonly provides the Bash 5.2 family, so commands are also tested in the stated Ubuntu environment rather than assuming every newer feature exists.
2. **REF-0090 — POSIX.1-2024 Shell Command Language.** The normative portable-shell baseline. Use it to distinguish standard shell behavior from Bash-specific arrays, `[[ ]]`, `PIPESTATUS`, process substitution, and other extensions.
3. **REF-0091 — ShellCheck official project.** The static-analysis tool and diagnostic documentation used for common quoting, expansion, conditional, pipeline, and portability defects. A tool result remains version- and configuration-scoped evidence.
4. **REF-0092 — GNU Coreutils `timeout`.** The primary utility documentation for duration syntax, signal choice, kill-after behavior, and exit statuses. Test exact options with the installed version.
5. **REF-0093 — GNU Coreutils `mktemp`.** The primary utility documentation for exclusive unpredictable temporary file and directory creation. Secure creation still requires parent, permission, ownership, state, and cleanup design.
6. **REF-0094 — Linux `signal(7)`.** Linux signal concepts, standard signals, dispositions, and the critical fact that SIGKILL cannot be caught, blocked, or ignored.
7. **REF-0095 — util-linux `flock(1)`.** Advisory-lock invocation, nonblocking and timeout behavior, conflict statuses, descriptor form, and filesystem cautions.
8. **REF-0096 — GNU Coreutils manual.** Primary behavior for common utilities used in path, record, stat, sorting, and verification workflows.

All explanations in this lesson paraphrase primary sources. No external command is safe merely because it appears in a manual; target authorization and surrounding state contracts remain local decisions.

### Review boundaries

Last technical review: **2026-08-02**. Scheduled review: **2027-02-02**, or sooner when Ubuntu's supported Bash/coreutils/util-linux packages, ShellCheck rules, POSIX interpretation, lab safety contract, or website schema changes.

At review time:

- run the full content and schema validators;
- run `bash -n` and ShellCheck on every lab script;
- run normal-user lifecycle and root refusal on Ubuntu 24.04;
- rerun hostile-argument, unexpected-child, altered-fixture, repeated setup, independent raw gate, recovery, and cleanup checks;
- compare commands with installed manual behavior and versions;
- scan for private names, internal URLs, credentials, secret-shaped data, mojibake, and unsafe copy-paste blocks;
- verify the site route, search, diagrams, dark mode, keyboard use, and links;
- keep `contentStatus` non-mastery until independent learner evidence is reviewed.

### Related learning path

- **LES-0009:** safe local workbench, Git states, secrets, and rollback boundaries.
- **LES-0002:** shell survival and the foundational command environment.
- **LES-0010:** block I/O and storage behavior that can make file automation stall or fail.
- **LES-0011:** namespaces and cgroups that change process, filesystem, and resource evidence.
- **LES-0013:** TCP, UDP, socket, timeout, and resource evidence behind network-facing automation.
- Future automation chapters should add Python, Go, APIs, tests, packaging, CI/CD, and release engineering without weakening this boundary model.

### Final field rule

When you inherit a Bash script during an incident, do not ask only, “Which command failed?” Ask:

```text
What bytes became which arguments?
Which status reached which caller?
What state committed before failure?
Who owns the authoritative truth?
What can be retried without another effect?
How will the real operation and cleanup be proven?
```

If the script cannot answer those questions, the next task is not a clever one-liner. The next task is to give the automation a contract.
