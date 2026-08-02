---
{
  "schemaVersion": 1,
  "kind": "lesson",
  "id": "LES-0009",
  "aliases": ["V03-L01", "safe-local-workbench"],
  "curriculumIds": ["SCM-001"],
  "slug": "safe-local-workbench",
  "route": "/book/engineering/safe-local-workbench",
  "order": 1,
  "volume": "03-engineering-delivery",
  "title": "Safe local engineering workbench: shell, Git states, secrets, and rollback",
  "summary": "Build a local Ubuntu or WSL workbench where every command has a known boundary, every Git change can be inspected before it moves, secrets stay outside history, and cleanup or rollback is proven instead of assumed.",
  "domain": "engineering",
  "level": {
    "from": "foundation",
    "to": "advanced"
  },
  "estimatedMinutes": 300,
  "prerequisiteLessonIds": ["LES-0007", "LES-0008"],
  "prerequisiteCurriculumIds": ["FND-001"],
  "testedEnvironments": [
    {
      "platform": "Ubuntu",
      "version": "24.04 LTS",
      "support": "required",
      "notes": "The lab runs as a normal non-root user with Bash, Git, GNU find, and core utilities. It creates only a small local repository under one guarded lesson-owned temporary root, opens no port, performs no network operation, and installs nothing."
    },
    {
      "platform": "Windows Subsystem for Linux (WSL 2) Ubuntu",
      "version": "24.04 LTS",
      "support": "supported",
      "notes": "The same lab is supported. For Linux-heavy repositories, use the WSL Linux filesystem rather than /mnt/c when practical for performance and Linux permission semantics; moving an existing repository is a separate reviewed operation."
    },
    {
      "platform": "Shared, production, CI/CD, and hosted Git environments",
      "version": "provider-neutral concepts",
      "support": "concept-only",
      "notes": "The collaboration, protected-branch, signing, credential, and incident sections explain production decisions but make no remote request, rewrite no shared history, and change no hosted repository."
    }
  ],
  "targetRoles": [
    "site-reliability-engineer",
    "devops-engineer",
    "platform-engineer",
    "production-engineer",
    "cloud-infrastructure-engineer",
    "data-platform-engineer",
    "software-engineer",
    "technical-lead"
  ],
  "learningObjectives": [
    "Identify the host, shell, filesystem, repository root, effective identity, Git worktree, index, object database, branch, and remote as separate state and trust boundaries.",
    "Predict shell parsing, expansion, quoting, redirection, pipeline, and exit-status behavior before running a command that reads or changes files.",
    "Decode Git status and diff evidence across the working tree, index, HEAD, refs, and objects without treating clean status as proof that no secret or risk exists.",
    "Create a reviewable change, stage intentionally, inspect the exact staged snapshot, and choose commit, restore, revert, reset, or reflog recovery according to publication and collaboration boundaries.",
    "Prevent common credential leaks, respond correctly when a secret reaches history, and explain why ignore rules and history rewriting do not revoke an exposed credential.",
    "Use bounded setup, verification, and cleanup contracts that refuse root, symlinks, out-of-scope paths, unexpected top-level artifacts, foreign ownership, special files, and unreviewed remote access.",
    "Design a repeatable local-to-CI workflow with explicit prerequisites, version evidence, narrow diffs, rollback awareness, and sanitized handoff artifacts.",
    "Explain Git object, ref, merge, rebase, conflict, bisect, reflog, worktree, hook, signing, and protected-workflow trade-offs at an operationally useful level."
  ],
  "productionSignals": [
    "A command is about to run from an unknown directory, with an unknown effective user, against a path assembled from an unchecked variable or wildcard.",
    "Git status contains staged, unstaged, untracked, ignored, conflicted, renamed, or deleted paths that the operator cannot explain line by line.",
    "A local check passes but CI fails because shell, filesystem, case sensitivity, executable bits, line endings, dependency versions, environment variables, or working directory differ.",
    "A credential-like file is ignored now but may already exist in an earlier commit, stash, tag, reflog, fork, cache, artifact, or another clone.",
    "A proposed reset, clean, rebase, force push, history rewrite, or broad delete would cross from private reversible state into shared or hard-to-recover state.",
    "A rollback restores files or a process but the required test, artifact, deployment input, customer operation, or audit record has not been verified.",
    "A repository contains generated output, local state, editor files, build caches, or platform-specific artifacts whose ownership and cleanup policy is unclear.",
    "A script reports success even though an earlier pipeline stage failed, an unset variable expanded unexpectedly, or cleanup ran against a different path than intended."
  ],
  "diagrams": [
    {
      "id": "LES-0009-DIA-001",
      "title": "Local workbench boundaries",
      "direction": "hierarchical",
      "boundaries": ["Windows host when WSL is used", "Ubuntu or WSL distribution", "shell process and effective identity", "filesystem and repository root", "tool and dependency versions", "local Git state", "remote and CI boundary"],
      "evidencePoints": ["kernel and release", "os-release", "pwd and id", "realpath and mount type", "command resolution and version", "git status and rev-parse", "declared remote names and CI metadata"],
      "textAlternative": "The operator enters an Ubuntu shell inside either a Linux host or WSL, selects an identity and filesystem path, runs versioned tools inside one repository, and reaches a remote or CI system only through a separate authorized boundary; evidence is collected at each transition."
    },
    {
      "id": "LES-0009-DIA-002",
      "title": "Git's four visible states and object ownership",
      "direction": "left-to-right",
      "boundaries": ["working tree", "index", "HEAD commit and local object database", "named refs", "remote repository"],
      "evidencePoints": ["git diff", "git diff --cached", "git show HEAD", "git branch and reflog", "fetch or push result when explicitly authorized"],
      "textAlternative": "A file starts in the working tree, git add copies selected content into the index, git commit writes immutable objects and moves a local branch ref, and an explicit network operation later exchanges objects and refs with a remote; restore, reset, revert, and force push act on different boundaries."
    },
    {
      "id": "LES-0009-DIA-003",
      "title": "Predict, inspect, change, verify, and clean",
      "direction": "cyclic",
      "boundaries": ["declare scope", "capture baseline", "predict", "make one bounded change", "inspect resulting state", "verify intended outcome", "prove rollback or cleanup", "record sanitized evidence"],
      "evidencePoints": ["safety card", "status and versions", "expected files and exit status", "narrow command", "diff and logs", "targeted test", "absence or restored-state proof", "reviewable handoff"],
      "textAlternative": "A safe work loop begins with scope and baseline, records a prediction, makes one bounded change, inspects the resulting Git and filesystem state, verifies the real outcome, proves cleanup or rollback, and records sanitized evidence before beginning the next loop."
    }
  ],
  "commands": [
    {
      "id": "LES-0009-CMD-001",
      "question": "Which operating system, kernel, shell, identity, and current directory own this terminal?",
      "risk": "read-only",
      "command": "cat /etc/os-release; uname -sr; printf 'shell=%s\\n' \"$SHELL\"; id; pwd; realpath -- .",
      "runFrom": "The exact Ubuntu 24.04 or WSL 2 Ubuntu terminal that will perform the work",
      "expectedBranches": [
        {
          "when": "Ubuntu 24.04, the expected kernel or WSL kernel, a nonzero effective UID, and the intended canonical path are visible",
          "meaning": "The current process boundary matches the lesson's supported baseline.",
          "nextEvidence": "Locate the repository and required tools; this output does not yet prove that the current directory is a Git worktree."
        },
        {
          "when": "The OS, identity, or path is unexpected",
          "meaning": "A foundational assumption is false before any repository change occurs.",
          "nextEvidence": "Stop and move to the intended normal-user shell and path; do not compensate with sudo."
        }
      ],
      "proves": "The displayed release metadata, kernel string, configured shell value, process identity, lexical directory, and resolved directory at that moment.",
      "doesNotProve": "Repository ownership, tool provenance, WSL version by itself, safe credentials, clean Git state, or permission to mutate anything."
    },
    {
      "id": "LES-0009-CMD-002",
      "question": "Am I inside the intended Git worktree, and what exact root and metadata directory does Git resolve?",
      "risk": "read-only",
      "command": "git rev-parse --is-inside-work-tree && git rev-parse --show-toplevel && git rev-parse --absolute-git-dir",
      "runFrom": "The candidate repository directory, before running project commands",
      "expectedBranches": [
        {
          "when": "All three commands succeed and the paths match the intended repository",
          "meaning": "Git recognizes this directory as part of that worktree and identifies its object and ref metadata directory.",
          "nextEvidence": "Inspect branch and status before deciding whether the worktree is safe to use."
        },
        {
          "when": "A command fails or a parent repository is returned",
          "meaning": "The directory is outside Git or belongs to a different enclosing worktree than expected.",
          "nextEvidence": "Stop; locate the intended repository explicitly rather than initializing or changing the discovered parent by accident."
        }
      ],
      "proves": "Git's current worktree membership and resolved top-level and metadata paths for this invocation.",
      "doesNotProve": "A clean worktree, trustworthy history, correct remote, authorization, safe hooks, or that nested untracked repositories are absent."
    },
    {
      "id": "LES-0009-CMD-003",
      "question": "Which branch and paths differ across HEAD, index, and working tree in a stable machine-readable form?",
      "risk": "read-only",
      "command": "git status --porcelain=v1 --branch --untracked-files=all",
      "runFrom": "The verified repository root",
      "expectedBranches": [
        {
          "when": "Only a branch line appears",
          "meaning": "Git reports no staged, unstaged, or untracked path under this status scope.",
          "nextEvidence": "Check ignored and sensitive paths plus the intended revision; clean status is not a security or correctness proof."
        },
        {
          "when": "Two status columns and one or more paths appear",
          "meaning": "The left column describes index versus HEAD and the right describes working tree versus index; special pairs identify untracked or conflicted state.",
          "nextEvidence": "Decode every pair, then inspect unstaged and staged diffs separately before any restore, commit, or cleanup."
        }
      ],
      "proves": "Git's porcelain-v1 branch and path-state classification for the current index and working tree at that instant.",
      "doesNotProve": "File intent, secret absence, semantic correctness, ignored-file absence, remote parity, or safety of discarding a path."
    },
    {
      "id": "LES-0009-CMD-004",
      "question": "What unstaged content differs from the selected index snapshot, and are there whitespace errors?",
      "risk": "read-only",
      "command": "git diff --check && git diff --stat && git diff --",
      "runFrom": "The verified repository root after status",
      "expectedBranches": [
        {
          "when": "The check succeeds and a patch appears",
          "meaning": "The patch is the tracked working-tree difference from the index and passed Git's configured whitespace-error check.",
          "nextEvidence": "Review each hunk for intent and sensitive content; inspect the staged snapshot separately."
        },
        {
          "when": "The check fails or the patch is empty",
          "meaning": "Whitespace errors stopped the chain, or no tracked unstaged difference exists; untracked and ignored files are not shown.",
          "nextEvidence": "Use the exit status and prior status output to choose a path-specific inspection rather than assuming no changes."
        }
      ],
      "proves": "The tracked unstaged patch, its summary, and the configured whitespace check only when preceding commands succeed.",
      "doesNotProve": "The contents of untracked or ignored files, correctness, test success, secret absence, or what is staged for commit."
    },
    {
      "id": "LES-0009-CMD-005",
      "question": "What exact snapshot would the next commit record relative to HEAD?",
      "risk": "read-only",
      "command": "git diff --cached --check && git diff --cached --stat && git diff --cached --",
      "runFrom": "The verified repository root after any deliberate staging",
      "expectedBranches": [
        {
          "when": "A staged patch appears and every hunk is intended",
          "meaning": "The index differs from HEAD by that displayed tracked content and passes the configured whitespace check.",
          "nextEvidence": "Run targeted validation and inspect identity and message before committing."
        },
        {
          "when": "The patch is empty or the check fails",
          "meaning": "Nothing is staged, or a whitespace condition stopped the chain.",
          "nextEvidence": "Return to status and path-specific add or restore decisions; do not use a broad add merely to make output appear."
        }
      ],
      "proves": "The index-versus-HEAD patch that a normal next commit would snapshot, subject to concurrent-change limits.",
      "doesNotProve": "The final commit identity, hook behavior, remote acceptance, untracked content, semantic validity, or absence of encoded secrets."
    },
    {
      "id": "LES-0009-CMD-006",
      "question": "Which commit and object types form the current local snapshot?",
      "risk": "read-only",
      "command": "git log -5 --oneline --decorate --no-show-signature; git cat-file -t HEAD; git cat-file -t HEAD^{tree}; git ls-tree -r --name-only HEAD",
      "runFrom": "The verified local repository",
      "expectedBranches": [
        {
          "when": "The log, commit type, tree type, and tracked paths appear",
          "meaning": "HEAD resolves to a commit whose tree names the displayed snapshot paths in the reachable local history.",
          "nextEvidence": "Use show or cat-file on a selected object when internals matter; avoid exposing sensitive blob content in shared logs."
        },
        {
          "when": "HEAD is unborn, missing, or corrupt",
          "meaning": "The repository has no first commit or cannot resolve the requested object graph.",
          "nextEvidence": "Distinguish a new repository from object corruption before attempting repair."
        }
      ],
      "proves": "Resolution and types of selected local objects and paths in HEAD's tree.",
      "doesNotProve": "Object trust, author identity, signature validity, remote retention, content safety, or that unreachable objects do not exist."
    },
    {
      "id": "LES-0009-CMD-007",
      "question": "Which ignore rule, if any, matches one exact local secret filename?",
      "risk": "read-only",
      "command": "git check-ignore -v -- .env.local",
      "runFrom": "The verified repository root using a placeholder path, never a secret value",
      "expectedBranches": [
        {
          "when": "A source file, rule line, pattern, and path appear",
          "meaning": "Git found an ignore rule matching that currently untracked path.",
          "nextEvidence": "Confirm the path is not already tracked or present in history; an ignore match is prevention for untracked state, not remediation."
        },
        {
          "when": "The command exits one with no output",
          "meaning": "No configured ignore rule matches the path under current rules.",
          "nextEvidence": "Add and review the narrow rule before creating real local credentials, and use approved injected secrets in real workflows."
        }
      ],
      "proves": "Whether Git's current ignore evaluation matches that exact path and which rule supplied the match.",
      "doesNotProve": "That the file is untracked, contains no credential, never existed in history, is absent from artifacts, or that an exposed credential remains safe."
    },
    {
      "id": "LES-0009-CMD-008",
      "question": "Does the bounded lesson harness accept this normal-user environment and clean state?",
      "risk": "read-only",
      "command": "bash book/labs/LES-0009-safe-local-workbench/lab.sh check",
      "runFrom": "Repository root in Ubuntu 24.04 or WSL 2 Ubuntu 24.04",
      "expectedBranches": [
        {
          "when": "The environment is ready and state is absent",
          "meaning": "The implemented OS, UID, tool, /tmp, descriptor, and orphan checks accept the current boundary.",
          "nextEvidence": "Record the setup prediction, then create one isolated workbench."
        },
        {
          "when": "The command refuses",
          "meaning": "A tested prerequisite or state invariant is not satisfied.",
          "nextEvidence": "Preserve the refusal and fix the environment deliberately; never weaken path or ownership guards."
        }
      ],
      "proves": "Only that the harness's current read-only preflight accepted the environment and registered state at that moment.",
      "doesNotProve": "Future mutation safety, Git mastery, absence of every filesystem attack, or permission to use any production repository."
    },
    {
      "id": "LES-0009-CMD-009",
      "question": "Can the lab create an isolated local repository, expose both Git columns, and restore the modeled operation?",
      "risk": "mutating-bounded",
      "command": "bash book/labs/LES-0009-safe-local-workbench/lab.sh setup && bash book/labs/LES-0009-safe-local-workbench/lab.sh run baseline && bash book/labs/LES-0009-safe-local-workbench/lab.sh inject guided && bash book/labs/LES-0009-safe-local-workbench/lab.sh observe status",
      "runFrom": "Repository root after an accepted check and written predictions",
      "expectedBranches": [
        {
          "when": "Setup, baseline, injection, and status complete in sequence",
          "meaning": "The harness created one private local-only Git workbench and exposed its deterministic guided mixed state.",
          "nextEvidence": "Decode each status pair, then inspect working-tree, staged, ignored, and history views before recovery."
        },
        {
          "when": "Any stage refuses",
          "meaning": "The command chain stopped at the first failed lifecycle or safety condition.",
          "nextEvidence": "Retain that output and run supported status only if state validation accepts; do not edit the descriptor or temporary root."
        }
      ],
      "proves": "Successful execution of the named bounded lifecycle stages and status emitted by the versioned fixture.",
      "doesNotProve": "That the learner interpreted the states, a real repository is safe, secret handling is complete, or recovery and cleanup occurred.",
      "cleanup": "Use supported recover, verify-operation, and guarded cleanup commands; never manually delete the random root."
    },
    {
      "id": "LES-0009-CMD-010",
      "question": "Did selective recovery restore the baseline operation and did guarded cleanup remove only the lesson-owned boundary?",
      "risk": "mutating-bounded",
      "command": "bash book/labs/LES-0009-safe-local-workbench/lab.sh recover && bash book/labs/LES-0009-safe-local-workbench/lab.sh verify-operation && bash book/labs/LES-0009-safe-local-workbench/lab.sh cleanup && bash book/labs/LES-0009-safe-local-workbench/lab.sh check",
      "runFrom": "The active lesson workbench after evidence is retained in sanitized form",
      "expectedBranches": [
        {
          "when": "Recovery and operation verification pass, cleanup proves absence, and check independently reports absent state",
          "meaning": "The model returned to its declared clean local snapshot, then cleanup removed the exact validated workbench and descriptor at that point.",
          "nextEvidence": "Retain only sanitized results and explain what these checks do not establish."
        },
        {
          "when": "Any command refuses or fails",
          "meaning": "The chain stops; restoration or cleanup is not proven.",
          "nextEvidence": "Preserve the first diagnostic. Do not substitute reset, recursive manual deletion, force, sudo, or a different path."
        }
      ],
      "proves": "Only the fixture's recovery assertions and cleanup's exact point-in-time boundary checks when every chained command succeeds.",
      "doesNotProve": "Production rollback, remote history safety, credential revocation, concurrency safety against a malicious same-UID process, learner mastery, or future absence.",
      "cleanup": "This command includes supported cleanup and a separate read-only absence check."
    },
    {
      "id": "LES-0009-CMD-011",
      "question": "Does the separate clean-state verifier accept positive lifecycle and negative safety tests?",
      "risk": "mutating-bounded",
      "command": "bash book/labs/LES-0009-safe-local-workbench/verify.sh",
      "runFrom": "Repository root with no active LES-0009 learner state",
      "expectedBranches": [
        {
          "when": "The verifier reports every case, refusal, answer-isolation check, and cleanup proof passed",
          "meaning": "The encoded harness assertions passed in this local environment for that run.",
          "nextEvidence": "Treat this as lab engineering evidence, not a substitute for the learner transfer submission."
        },
        {
          "when": "The verifier stops",
          "meaning": "An environment, lifecycle, output, refusal, isolation, or cleanup assertion failed.",
          "nextEvidence": "Retain the first error and inspect exact state; do not relax a guard merely to obtain green output."
        }
      ],
      "proves": "The verifier's implemented assertions for its run, including symlink and out-of-scope refusal with external-target preservation.",
      "doesNotProve": "Complete shell security, freedom from every race, production equivalence, answer absence outside its scoped scan, or learner mastery.",
      "cleanup": "The verifier traps its own state and must end with descriptor and root absence; if it cannot, preserve the exact diagnostic."
    }
  ],
  "labs": [
    {
      "id": "LES-0009-LAB-001",
      "title": "Read and recover a mixed Git worktree safely",
      "mode": "guided",
      "environment": "Ubuntu 24.04 LTS or WSL 2 Ubuntu 24.04 LTS; normal non-root user; Bash, Git, GNU find and core utilities; real root-owned sticky /tmp; local disposable repository only; no install, sudo, network, remote, port, container, background worker, sleep, host pressure, real credential, employer data, or production path",
      "timeMinutes": 70,
      "privilege": "Normal non-root user only; effective UID 0 is refused and scripts never invoke sudo",
      "network": "None; the generated repository has no remote and the harness permits no fetch, pull, push, clone, download, login, socket, or hosted API operation",
      "changes": [
        "Creates one mode-0700 lesson-prefixed random root under /tmp, one UID-scoped mode-0600 descriptor, one exact sentinel, and one small local Git repository with synthetic identity and placeholder-only files.",
        "Records a deterministic baseline and one guided or transfer case; cases create only small tracked, staged, unstaged, untracked, and ignored fixture files inside that repository.",
        "Selective recovery uses path-scoped Git restore plus exact regular-file removal; verification checks HEAD identity, branch, clean status, absent remote, expected tracked bytes, and absence of fixture-local ignored state."
      ],
      "abortConditions": [
        "The effective UID is zero; Ubuntu 24.04 or a required tool is absent; /tmp is not the real root-owned mode-1777 sticky directory; or an existing descriptor or unregistered lesson-root candidate is present.",
        "The descriptor, root, sentinel, canonical path, prefix, owner, mode, direct-entry allowlist, repository root, branch, object identity, no-remote invariant, lifecycle record, or expected case shape differs from the applicable contract.",
        "Any symlink, hard-linked regular file, special file, foreign-owned item, cross-device item, excessive file count, or oversized file is found within the lesson root.",
        "A supported command returns nonzero, an unexpected top-level artifact appears, an arbitrary observe or inject argument is requested, operation verification fails, or exact cleanup cannot prove the registered root and descriptor absent."
      ],
      "recovery": "Use supported status and read-only observations while strict case validation accepts. Use recover only after case evidence is understood; it restores exact fixture paths and never rewrites shared history. Reset is guarded cleanup followed by new setup. If validation or cleanup refuses, stop and retain the diagnostic; never use sudo, force, a broad path, recursive manual deletion, descriptor editing, or an external repository as a substitute.",
      "cleanupProof": "Cleanup validates the exact mode-0600 current-UID descriptor, canonical lesson-prefixed mode-0700 root, sentinel identity, direct-entry allowlist, and every descendant as current-UID, same-device, non-symlink regular file or directory with bounded count and size; regular files must have one link. It then uses GNU find with physical traversal, one filesystem, the exact validated root, depth-first deletion, and final rmdir; descriptor removal occurs last. It proves both exact paths absent and performs a point-in-time scan for unregistered current-UID lesson roots. Cleanup refuses unknown top-level entries, links, special files, foreign ownership, cross-device content, or a changed descriptor. This bounds ordinary lab cleanup but cannot defeat a malicious concurrent process running as the same UID.",
      "path": "book/labs/LES-0009-safe-local-workbench"
    }
  ],
  "incidents": [
    {
      "id": "LES-0009-INC-001",
      "signal": "An engineer sees staged, unstaged, untracked, deleted, and ignored paths, then proposes git reset --hard and a broad clean because a deployment fix is urgent.",
      "firstThought": "This is an ownership and state-classification problem before it is a cleanup problem; name what lives in HEAD, index, working tree, and ignored space, and identify which work belongs to whom.",
      "safePath": "Freeze broad mutation; capture status, worktree and staged diffs, branch, HEAD, and owners; preserve a patch or worktree when needed; choose path-scoped restore or a new commit according to publication state; run targeted tests and verify the intended deployment input.",
      "trap": "Hard reset does not remove every untracked file, clean does not understand human ownership, and using both can irreversibly erase work while leaving ignored secrets or the production cause untouched."
    },
    {
      "id": "LES-0009-INC-002",
      "signal": "A token-shaped value appears in a commit pushed to a shared remote, and someone suggests adding the file to .gitignore and deleting it in the next commit.",
      "firstThought": "Treat the credential as exposed now. Rotation or revocation is the containment action; Git cleanup is a separate evidence-retention and distribution problem.",
      "safePath": "Notify security and repository owners; revoke or rotate; preserve evidence without repeating the value; determine which refs, clones, forks, caches, artifacts, logs, and deployments it reached; coordinate any history rewrite; add runtime secret delivery, scanning, and review; verify old credential rejection.",
      "trap": "Ignore rules affect untracked-path selection, and a later deletion adds another commit; neither removes earlier blobs nor makes an already copied credential safe."
    },
    {
      "id": "LES-0009-INC-003",
      "signal": "A build works in WSL but fails in Linux CI with a missing script, permission denied, or differently cased filename even though the repository is clean.",
      "firstThought": "Compare environments and the committed snapshot: filesystem semantics, executable bit, line endings, case, path, shell, dependency version, and ignored local state are candidates.",
      "safePath": "Record OS, shell, working directory, tool versions, commit ID, status, tracked path spelling, executable mode, attributes, and environment contract in both places; reproduce in a clean worktree; correct the smallest committed cause and verify the CI entry point.",
      "trap": "Chmod in a running job, renaming only on a case-insensitive filesystem, or copying a local ignored file can make one run pass while the repository remains unreproducible."
    }
  ],
  "assessmentIds": ["ASM-0010", "ASM-0011", "ASM-0012"],
  "referenceIds": ["REF-0025", "REF-0026", "REF-0027", "REF-0028", "REF-0029", "REF-0030", "REF-0031", "REF-0032"],
  "contentStatus": "substantive-draft",
  "masteryBoundary": "publication-does-not-award-mastery",
  "lastReviewed": "2026-08-02",
  "reviewAfter": "2026-11-02",
  "limitations": [
    "The lab is a small local Git repository with deterministic fixture states. It is not a hosted collaboration service, CI runner, signing infrastructure, large monorepo, merge queue, or production deployment.",
    "The lesson owns SCM-001 in this curriculum but does not award source-control mastery by publication; reviewed original evidence from guided, transfer, later recall, collaboration, conflict, recovery, and capstone work remains required.",
    "Shell parsing and secret response are workbench safety practices here, not completion of AUT-001 or SEC-001; dedicated automation and security lessons add programming, tests, threat models, identity, policy, and incident exercises.",
    "Git restore, reset, revert, reflog, rebase, worktree, signing, and history rewrite behavior depends on exact operands, reachability, retention, server policy, hooks, and collaboration state. Inspect current official documentation and repository policy before real use.",
    "Ignore rules reduce accidental selection of untracked files but do not encrypt data, remove tracked history, revoke credentials, protect build artifacts, or stop another tool from reading a file.",
    "The cleanup verifier exercises important refusal boundaries but cannot prove absence of every filesystem race, malicious same-UID process, kernel fault, Git vulnerability, or future path recreation.",
    "No command output, clean status, successful commit, verifier pass, page completion marker, or copied answer establishes learner mastery; an authorized reviewer must evaluate original evidence and transfer reasoning."
  ]
}
---

# Safe local engineering workbench: shell, Git states, secrets, and rollback

## What you see and first thought

You open Ubuntu, paste a command, and get an error. Or Git shows five changed files when you expected one. The dangerous reaction is, "How do I make this red text disappear?" The senior reaction is different:

> Before I change anything, which machine, shell, user, directory, filesystem, repository, revision, and state boundary am I actually touching?

That sentence is your seat belt. A command is not safe because it is familiar. It is safe only when its target, effect, recovery path, and evidence are understood.

Consider these prompts:

~~~text
sreuser@workstation:~/work/payments$
sreuser@workstation:/mnt/c/Users/.../payments$
~~~

They may show the same username and project name, yet the files can live on different filesystems with different performance, permission, case-sensitivity, line-ending, watcher, and interoperability behavior. One may be the intended clone; the other may be a stale second clone. `pwd` is not decoration. It is target evidence.

Now imagine `git status --short` prints:

~~~text
MM service.conf
?? notes.txt
~~~

`MM` is not vaguely "modified twice." The first `M` says the **index** differs from `HEAD`; the second says the **working tree** differs from the index. There are three versions of `service.conf`. `??` says Git has no tracked or staged version of `notes.txt`. Until you decide which version is intended and who owns the file, a broad reset is guessing with other people's work.

The repeatable workbench loop is:

~~~text
know boundary -> capture baseline -> predict -> change narrowly
              -> inspect state -> verify outcome -> prove cleanup
~~~

The target is not memorizing Git commands. The target is controlling state under pressure.

## Terms before commands

**Host** is the computer or virtualized environment providing CPU, memory, storage, and a kernel. With WSL 2, Windows is the outer host and the Linux distribution runs with a Linux kernel in a managed virtual-machine boundary.

**Distribution** is the packaged Linux user space - Ubuntu 24.04 here. It supplies libraries, package metadata, shells, and utilities. A kernel string and an Ubuntu release string answer different questions.

**Shell** is the command interpreter. Bash reads characters, parses words and operators, performs expansions and redirections, finds a command, runs it, and returns an exit status. The terminal is the user interface; Bash is the interpreter; the command is a program or shell construct.

**Effective user ID (EUID)** is the identity the kernel uses for most permission decisions. UID 0 is root. `sudo` starts an authorized command with another identity; it is not a cure for a wrong path, wrong owner, or bad hypothesis.

**Working directory** is where relative paths begin. `./config` means a different object after `cd`. A safe script resolves its base from a trusted location and validates the final path before mutation.

**Canonical path** is the resolved path after dot components and symbolic links are accounted for. `realpath -- .` helps expose that identity. It still does not grant ownership or permission.

**Mount** joins a filesystem into the directory tree. `/home` and `/mnt/c` can present different filesystem implementations even though both look like ordinary paths. In WSL, keep Linux-tool-heavy work in the Linux filesystem when practical.

**Environment** is a set of name/value strings inherited by child processes. Environment variables are convenient inputs, not a secret vault. They can leak through debugging, child processes, logs, shell history, or platform inspection.

**Exit status** is an integer returned by a command. Conventionally zero means success and nonzero means failure or a negative result, but meaning belongs to the command. `git check-ignore` returning one means "not ignored," not "Git crashed." `$?` contains only the latest foreground pipeline's status.

**Standard input, output, and error** are file descriptors 0, 1, and 2. `>` replaces a file with standard output; `>>` appends; `2>` redirects error. The shell prepares redirection before executing the command, so a redirection can truncate a file even if the program later fails.

**Pipeline** connects one command's output to another's input. Bash normally returns the last command's status. `set -o pipefail` exposes a failed earlier stage, but does not make partial output transactional.

**Quoting** controls shell interpretation. Single quotes preserve literal characters. Double quotes still permit parameter and command expansion but prevent ordinary word splitting and pathname expansion of the result. An unquoted `$path` may become several arguments or wildcard matches. Quote data, validate paths, and keep code separate from data.

**Repository** is Git history and metadata plus, usually, a working tree. A **working tree** contains files you edit. The **index** is the proposed next snapshot. `HEAD` normally names the current commit through a branch ref. The **object database** stores blobs, trees, commits, and annotated tags.

A **blob** stores file content, not its filename. A **tree** maps names to objects plus modes. A **commit** points to a tree, parents, metadata, and message. A **ref** is a movable name such as `refs/heads/main`. Git is a snapshot graph, not merely a bag of line changes.

A **remote** is named configuration for another repository, not a live connection. `origin` is convention, not proof of ownership. `fetch`, `pull`, and `push` cross the network boundary; status, diff, add, commit, restore, and log are local.

**Ignored** means an untracked path matches an ignore rule. It does not mean absent, encrypted, safe, deleted from history, or invisible to other tools.

**Rollback** means moving a system toward a known acceptable state. Restoring a local file, moving a private ref, creating an inverse commit, and redeploying a prior artifact are different mechanisms with different risks.

## Architecture map

~~~text
[Windows host, if WSL]
          |
          | virtualization + filesystem interop
          v
[Ubuntu 24.04 / Linux kernel]
          |
          | process identity, environment, cwd
          v
[Bash] -> [Git executable] -> [working tree + .git objects/refs]
                                      |
                         explicit network command only
                                      v
                         [remote Git service / CI]
~~~

Collect evidence at boundaries:

| Boundary | First evidence | Why it matters |
|---|---|---|
| Host to WSL | kernel release and WSL status when needed | Distinguishes WSL behavior from native Linux or a container. |
| Distribution | `/etc/os-release` | Establishes the supported user-space baseline. |
| Identity | `id`, ownership, modes | Explains permission and cleanup authority. |
| Shell to command | Bash version, `type -a`, `command -v` | Exposes aliases, functions, PATH choice, and executable location. |
| Directory to filesystem | `pwd`, `realpath`, `findmnt -T` | Reveals path identity and backing mount. |
| Directory to repository | `git rev-parse` | Prevents operating on an unintended parent or second clone. |
| Worktree to index | `git diff` and the right status column | Shows tracked edits not staged. |
| Index to HEAD | `git diff --cached` and left status column | Shows the proposed next snapshot. |
| Local to remote | approved remote identity and fetch/push result | Crosses trust, credential, collaboration, and network boundaries. |

Never paste a remote URL into a ticket without checking whether it embeds a username or credential. Often the remote **name** and repository policy are sufficient. Sanitize evidence at collection time.

Git's state architecture is:

~~~text
editor/build
    |
    v
WORKING TREE -- git add path --> INDEX -- git commit --> OBJECTS + BRANCH REF
    ^                              |                         |
    | git restore path             | restore --staged        | show/log
    +------------------------------+------------------------- HEAD

REMOTE is outside this diagram until fetch/pull/push is explicitly invoked.
~~~

`git add` copies current content into the index. If you edit again, the worktree diverges and status can show `MM`. Inspect the staged diff immediately before commit.

## Request or state path

A safe local change follows a state path:

~~~text
intent
 -> choose host/distribution/user
 -> choose canonical repository
 -> identify HEAD and branch
 -> inspect existing worktree/index ownership
 -> edit one bounded path
 -> inspect working-tree diff
 -> stage selected content
 -> inspect index diff
 -> run exact validation
 -> commit local snapshot
 -> review resulting object/ref
 -> request collaboration or deployment through policy
 -> verify consumer outcome
~~~

Every arrow can fail. A correct file in the wrong clone never reaches CI. An edit not staged never enters the commit. A commit on the wrong branch may not enter review. A local test using an ignored configuration can fail in a clean runner. A merged commit can still build the wrong artifact. Follow state, not the feeling of completion.

The shell has a path before Git sees arguments:

~~~text
typed characters
 -> tokenization and parsing
 -> expansion
 -> word splitting and pathname expansion where applicable
 -> redirections
 -> command lookup and execution
 -> exit status
~~~

If `target` is empty, `rm -r $target/*` is dangerous. Quoting alone is insufficient: `rm -r -- "$target"/*` still expands a wildcard and may target an unintended location. Safe automation needs a validated canonical target, ownership checks, a narrow allowlist, refusal on surprise, and exact cleanup semantics.

## Failure zoom

### The two-column status

~~~text
HEAD version A
     |
     | git add after edit B
     v
INDEX version B
     |
     | edit again to C
     v
WORKTREE version C

status:             MM service.conf
ordinary diff:      B -> C
cached diff:        A -> B
~~~

Running only `git diff` can miss the staged A-to-B change that will be committed. Running only cached diff misses later edits. `MM` tells you to inspect both.

### Ignored secret versus tracked history

~~~text
.gitignore matches .env.local
          |
          +--> an untracked file is omitted from ordinary status/add

but if it was tracked earlier:

commit C1 -> tree -> blob containing credential
          |
          +--> a later ignore rule does not change C1 or revoke it
~~~

Once a real credential is disclosed, assume exposure. Revoke or rotate it first. Then coordinate history treatment, clones, forks, caches, artifacts, logs, and prevention. Never repeat the value in an incident record.

### Local success, CI failure

~~~text
local = HEAD + ignored file + local modes + cached dependency
CI    = HEAD + declared inputs + runner filesystem + fresh process
~~~

"Works locally" and "fails in CI" are compatible when inputs differ. Make the contract visible: commit, tracked paths, executable modes, line endings, case, shell, versions, environment names, and working directory.

## Internals and state ownership

### Shell ownership

Bash owns interpretation before the target program begins. Redirection is created before program execution. Command substitution removes trailing newline characters. A failed producer can therefore leave an empty or partial file if the script mishandles status.

`set -Eeuo pipefail` is useful in many scripts: `-e` exits in many unhandled failure contexts, `-E` propagates an ERR trap further, `-u` rejects some unset-parameter uses, and `pipefail` exposes a failed pipeline stage. It is not a proof. Conditional lists, substitutions, traps, expected nonzero commands, and cleanup still require explicit design.

### Git object ownership

~~~text
blob(file bytes)
tree(name -> object + mode)
commit(tree + parent(s) + metadata + message)
annotated tag(name + target + tagger + message)
~~~

A branch is a ref that moves to a commit. A detached `HEAD` points directly to a commit; new commits may become hard to find after moving away unless a ref is created, although reflogs may retain them temporarily.

Commit hashes provide content-addressed integrity within Git's model, not human trust. Author fields are data. Cryptographic signing can authenticate an object according to key and policy, but does not make code correct.

### Merge, rebase, and conflicts

A merge can create a commit with two parents and preserve both lines of ancestry. A rebase copies changes onto a new base, creating new commit identities. Rebase is useful for private review cleanup; rewriting shared history forces collaborators to reconcile it.

A conflict means Git cannot safely choose one combined result under its merge rules. Conflict markers are not the whole state: the index can hold stage 1 base, stage 2 ours, and stage 3 theirs. Understand the intended behavior, resolve, stage the result, test it, and inspect the final diff. "Choose ours" or "choose theirs" is rarely a semantic review.

### Restore, reset, revert, reflog, and clean

`git restore` targets working-tree or index content. `git reset` moves or resets ref, index, or working-tree boundaries depending on mode and operands. `git clean` removes selected untracked files. These overlap in ordinary speech as "undo," but their blast radii differ.

A revert creates a new commit that attempts to invert another patch, preserving published history. Reverting a merge requires a mainline parent and influences later merges; data, schemas, and external effects still need separate recovery.

The reflog records recent local ref movements and can recover some commits after reset or rebase. It is local and expires; it is not a backup contract. Preserve a recovery ref promptly after verifying the object.

### Bisect, worktrees, hooks, and policy

`git bisect` searches a good-to-bad commit interval. The result is only as trustworthy as the test and reproducibility. Flaky tests or unbuildable intermediate commits can mislead it.

`git worktree` permits multiple checked-out trees connected to one repository. It can isolate work more safely than switching a dirty tree, but branch occupancy and per-worktree state matter. Always resolve the actual top level.

Client hooks provide fast feedback but can be absent or bypassed. Enforce critical shared controls with protected branches, required reviews and checks, server policy, least-privilege identities, and immutable artifact promotion.

## Evidence table

| Signal | What it proves | What it does not prove | Safest next evidence |
|---|---|---|---|
| `pwd` and `realpath -- .` | Lexical and resolved current directory now | Repository identity, ownership, mount, or intent | `git rev-parse`, `findmnt -T .`, `stat` |
| `id` shows nonzero UID | Current process is not root | File ownership, sudo absence, or authorization | Exact `stat` and owning policy |
| Porcelain status is clean | No reported staged, tracked-unstaged, or selected untracked paths | Ignored files, history secrets, remote parity, tests | Ignored/path checks, HEAD, validation |
| ` M file` | Worktree tracked content differs from index | Whether the edit is intended or safe | `git diff -- file` |
| `M  file` | Index differs from HEAD | Whether latest worktree bytes are staged | Cached diff plus ordinary diff |
| `MM file` | Both comparisons differ | Which of the three versions is correct | Inspect both diffs and intent |
| `?? file` | Path is untracked and not ignored | Ownership or disposability | Inspect type/content safely and ask owner |
| `!! file` in ignored status | Untracked path matches ignore rules | Secret safety or absence from history | `check-ignore`, `ls-files`, incident scope |
| Cached diff matches intent | Proposed snapshot patch was reviewed | Tests, hook effects, remote acceptance | Targeted validation and post-commit show |
| Local test passes | That test passed with current local inputs | Clean-runner reproducibility or full correctness | Reproduce declared CI entry point cleanly |
| Reflog names a lost commit | Local reflog currently reaches that object | Long-term retention or remote backup | Verify object and create recovery ref |
| Revert is deployed | New inverse change reached deployment | User recovery, data compatibility, cause | Real operation and integrity signals |
| Secret file is deleted later | Current tree may omit that path | Earlier blob removal or credential revocation | Rotate/revoke, scope exposure, coordinate cleanup |

Evidence itself has a boundary. Paths, usernames, URLs, hostnames, commit messages, and configuration may be sensitive. Sanitize only what is necessary while retaining fields needed to reason. A screenshot that hides every identity is useless; a raw terminal dump can leak a token. Design evidence before collection.

### Facts, interpretations, and decisions

| Kind | Example | Discipline |
|---|---|---|
| Observation | "Porcelain output showed `MM service.conf` at commit X." | Preserve command, scope, time, and output meaning. |
| Interpretation | "The index and worktree contain different edits." | State proof limits; do not invent human intent. |
| Decision | "Preserve both diffs and ask the owner before restore." | Record authority, expected result, abort, and recovery. |

This prevents a plausible story from silently becoming a fact.

## Command decoders

### Decode status

~~~bash
git status --porcelain=v1 --branch --untracked-files=all
~~~

- `git` is the executable selected through `PATH`.
- `status` compares `HEAD`, index, and worktree.
- `--porcelain=v1` asks for a stable format suitable for scripts.
- `--branch` adds branch/upstream state.
- `--untracked-files=all` lists individual untracked paths.

Entries begin `XY PATH`. `X` is index versus `HEAD`. `Y` is worktree versus index. Common codes are `M` modified, `A` added, `D` deleted, `R` renamed, `?` untracked, `!` ignored when requested, and unmerged combinations such as `UU`. Rename detection is similarity analysis, not proof of human intent.

### Decode the two diffs

~~~bash
git diff --check
git diff --
git diff --cached --check
git diff --cached --
~~~

The first pair addresses worktree versus index. The cached pair addresses index versus `HEAD`. `--check` reports whitespace errors instead of validating the file's language. The standalone `--` ends option parsing; later values are paths even if a filename begins with a hyphen.

In a command joined by `&&`, the next program runs only when the previous status is zero. That is a gate, not a transaction. Earlier programs may already have changed state.

### Decode selective restore

~~~bash
git restore --staged -- service.conf
git restore --worktree -- service.conf
~~~

The first command targets the index and normally copies from `HEAD` when no explicit source is provided. The worktree edit remains. The second targets the worktree and copies from the index. Running them in this order can return both destinations to `HEAD`, but only after you have proved that discarding both versions is intended.

Never shorten a high-risk command until you can name source and destination:

~~~text
source HEAD -> destination index
source index -> destination working tree
~~~

### Decode history and objects

~~~bash
git log -5 --oneline --decorate --no-show-signature
git cat-file -t HEAD
git cat-file -t 'HEAD^{tree}'
git ls-tree -r --name-only HEAD
~~~

`-5` limits log output. `--oneline` shows abbreviated IDs and subjects. `--decorate` shows refs. A subject is untrusted text and may contain sensitive data. `cat-file -t` reports an object type. `HEAD^{tree}` peels the commit to its tree. `ls-tree` lists paths recorded in the commit - not untracked, ignored, or worktree-only files.

An abbreviated ID is convenient only while unique. Use a full object ID for durable evidence.

### Decode ignore evidence

~~~bash
git check-ignore -v -- .env.local
git ls-files --error-unmatch -- .env.local
~~~

The first command returns the rule source, line, pattern, and matched path when ignored; status 1 means no match. The second succeeds when the path is tracked in the index. Neither prints file contents. A tracked path is not protected by adding a later ignore rule.

### Decode safe Bash options

~~~bash
set -Eeuo pipefail
umask 077
~~~

`umask 077` asks newly created files to remove group/other permissions from the requested mode. Existing files do not change. Filesystem behavior and later `chmod` still matter. Strict shell options make many failures visible, but expected nonzero statuses must be handled explicitly and cleanup targets must still be validated.

### The mutation card

Before a mutating command, fill this:

~~~text
target: exact canonical path or Git state
owner: person/team and effective UID
current evidence: status, diff, object, or test
expected change: named paths and states
success: observable consumer outcome
abort: unexpected path, state, output, or identity
recovery: exact supported inverse
cleanup proof: what must be absent or restored
~~~

If one field is unknown, gather evidence instead of increasing force.

## Decision path

~~~text
Know canonical root, branch, HEAD, identity?
  |-- no --> stop and establish them
  v
Explain every status entry and owner?
  |-- no --> inspect both diffs and ignored state; ask owner
  v
Private and uncommitted?
  |-- yes --> path-scoped preservation/restore may fit
  v
Local and unpublished commit?
  |-- yes --> preserved ref + reset/rebase may fit
  v
Published or consumed commit?
  |-- yes --> prefer auditable forward fix/revert; coordinate rewrite
  v
Credential crossed trust boundary?
  |-- yes --> revoke/rotate first; scope exposure
  v
Actual consumer outcome and integrity recovered?
  |-- no --> restoration is not proven
  v
Exact cleanup proven without crossing scope?
  |-- no --> stop and retain evidence
~~~

Use state, not vocabulary, to choose:

| Situation | First evidence | Usually safer direction |
|---|---|---|
| Your unstaged disposable edit | Ordinary path diff | Path-scoped worktree restore after prediction |
| Staged but uncommitted edit | Cached and ordinary diffs | Unstage or preserve; do not discard both blindly |
| Local unpublished bad commit | Branch, `HEAD`, reflog, consumers | Recovery ref, then reviewed ref repair |
| Published bad commit | Consumers, compatibility, policy | Revert or forward fix with operational verification |
| Shared rewrite required | Security and repository owners | Coordinated rewrite, clone/fork plan, protected recovery refs |
| Unknown untracked file | Type, owner, content classification | Preserve until owner and purpose are known |
| Exposed credential | Owning secret system and audit path | Rotate/revoke, then repository/distribution response |
| Local/CI mismatch | Exact commit plus both environments | Clean reproduction and smallest committed correction |

`git reset --hard`, `git clean`, rebases, and force pushes are not forbidden magic. They are sharp tools. Use them only when the exact state boundary, ownership, publication state, recovery reference, and policy make their blast radius appropriate. This lesson's lab never needs them.

## Guided Ubuntu lab

This lab builds a real but tiny local Git repository under one random, lesson-owned `/tmp` root. It uses synthetic identity and placeholder values only and never creates a remote.

From the book repository root:

~~~bash
cd book/labs/LES-0009-safe-local-workbench
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

Before injection, predict:

~~~text
service.conf gets one staged version and a later unstaged version
notes.txt is untracked
.env.local and scratch.log are ignored
HEAD and branch do not move
no remote exists
~~~

The status view should show `MM service.conf`. Explain the three versions. The worktree diff shows index-to-worktree. The staged diff shows `HEAD`-to-index. The ignored view names matching paths and rules but does not print the placeholder value.

Write a recovery prediction:

~~~text
After selective recovery, HEAD and main remain unchanged, tracked bytes match
the baseline, status is clean, no remote exists, and fixture-local temporary
files are absent.
~~~

Then run:

~~~bash
bash lab.sh recover
bash lab.sh verify-operation
bash lab.sh cleanup
bash lab.sh check
~~~

The verified operation is deliberately narrow. It proves the fixture's declared local state. It does not prove a production rollback, a remote workflow, or your understanding.

Run harness QA only from clean state:

~~~bash
bash verify.sh
~~~

The verifier runs guided and transfer lifecycles, repeated-operation and invalid-input refusals, unexpected top-level state, a symlink to an external target, a descriptor aimed outside the prefix, and an orphan temporary root. It verifies the external target survives. It cannot inspect your reasoning or award mastery.

### Why cleanup is stricter than a toy tutorial

A local Git repository contains variable internal files, so cleanup cannot list every object filename. Instead it proves a tight outer boundary:

1. descriptor path, mode, ownership, and exact four-line format;
2. canonical random root under `/tmp` with fixed prefix and mode;
3. sentinel identity and top-level allowlist;
4. every descendant is same-device, current-UID, non-symlink regular file or directory;
5. regular files are single-link, bounded in size, and total entries are bounded;
6. physical one-filesystem deletion targets only the validated root;
7. root and descriptor are absent afterward.

It refuses surprises. It documents the remaining limit: another malicious process with the same UID could race state after validation.

## Production transfer

### CI/CD repository

~~~text
developer worktree
 -> reviewed commit
 -> protected ref
 -> runner checkout at exact object ID
 -> declared tools and dependencies
 -> tests, scans, build
 -> immutable artifact and provenance
 -> approved promotion
 -> deployment
 -> user verification
~~~

Log the sanitized commit ID, runner image or host class, tool versions, job identity, declared inputs, artifact digest, and promotion decision. Do not dump environment variables or credential-bearing URLs. A retry is a new attempt; record which input or external state changed.

### Kubernetes or platform repository

~~~text
commit -> rendered manifest -> policy result -> API acceptance
       -> controller reconciliation -> workload readiness -> routed request
~~~

A merged manifest is desired-state input, not proof of applied state. Rollback may mean reverting desired state, changing a release object, or using an emergency control. Avoid two controllers fighting over the same field. Verify observed revision and the real request path.

### Data platform repository

Code rollback may be incompatible with data written under a new schema. Establish schema compatibility, checkpoint semantics, replay or deduplication behavior, lineage, and partial-output ownership. Git reproduces source; it does not undo durable external effects.

### Private cloud and infrastructure

A small source diff may replace a VM, network, or datastore. Plan output is evidence, not authorization. Check state backend identity, target scope, providers, dependencies, policy, maintenance window, rollback feasibility, and data protection before apply.

### Team collaboration

Branch policy should connect risk to control. Low-risk documentation may need light review; authentication, data migration, network policy, and deployment control need domain reviewers and stronger tests. Protected branches and required checks are guardrails, not proof. Emergency bypass needs named authority, audit, expiration, and follow-up.

## Reliability, security, observability, capacity, and cost

**Reliability:** Reproducibility reduces recovery time. Record material versions, use one supported entry point, keep checks deterministic where possible, and make a clean environment able to recreate the result. Another engineer should identify inputs, reproduce checks, and understand refusals.

**Security:** Minimize privilege. Never run a repository script with `sudo` merely because it failed. Inspect code, dependencies, and targets. Keep credentials in approved delivery systems, not source or examples. If exposure occurs, revoke or rotate before discussing history aesthetics.

**Observability:** Record transitions, not only "passed." Useful evidence includes purpose, repository object, path scope, exit status, changed-file summary, validation result, and cleanup proof. Avoid sensitive dumps and high-cardinality noise. A transcript without predictions and proof limits is not diagnosis.

**Capacity:** Status, index refresh, diff, checkout, hooks, install, and builds can be costly in monorepos or cross-filesystem WSL paths. Measure the slow boundary before disabling controls. Sparse checkout, partial clone, caches, and worktrees introduce their own correctness models.

**Cost:** Developer delay, CI minutes, artifact storage, cache transfer, runner capacity, and incidents all cost money. A fast unsafe workflow can be most expensive after secret exposure or corrupt history. Optimize measured repetition, not review and safety blindly.

| Choice | Benefit | Risk and control |
|---|---|---|
| WSL Linux filesystem for Linux tools | Better Linux I/O and semantics | Plan Windows access/backup; avoid duplicate clones |
| Dependency cache | Faster builds | Key by actual inputs; verify integrity; recover from stale cache |
| Rebase private branch | Linear review | New IDs; do not surprise collaborators |
| Revert published change | Auditable shared recovery | External state and data may not reverse |
| Client hook | Fast feedback | Bypassable; enforce critical controls in CI/server |
| History rewrite after exposure | Reduces normal reachability | Rotate first; coordinate clones/forks/caches and changed IDs |

## Traps and prevention

1. **Permission denied, so use sudo.** Identify owner, intended identity, mount, and policy. Privilege cannot correct a wrong target.
2. **Trust the prompt directory.** Verify `pwd`, `realpath`, and repository top level.
3. **Clean status means safe repository.** Consider ignored state, stashes, refs, history, submodules, worktrees, hooks, artifacts, and external state according to the question.
4. **Run only ordinary diff.** Inspect cached diff whenever the left status column is nonblank.
5. **Use `git add .` to simplify status.** Stage path-by-path or patch-by-patch; review the cached snapshot.
6. **Reset and clean before ownership.** Preserve evidence and classify every path.
7. **Treat reflog as backup.** It is local and expiring; create a verified recovery ref.
8. **Put secrets in a private repo.** Private access is not secret lifecycle management.
9. **Fix exposure with ignore.** Rotate/revoke, scope distribution, coordinate cleanup, then prevent recurrence.
10. **Paste raw terminal output.** Sanitize identities, paths, URLs, tokens, and customer data while retaining useful state evidence.
11. **Mix Windows and Linux tools over one live tree.** Choose a primary boundary and control line endings, modes, case, watchers, and concurrent mutation.
12. **Call rollback complete when files look old.** Verify artifact, deployment, compatibility, data, and consumer operation.
13. **Force push with plain `--force`.** Even force-with-lease needs exact ref expectations, ownership, coordination, and recovery; neither is a deployment rollback.
14. **Automate cleanup with a broad glob.** Validate an exact canonical owned boundary, reject links and surprises, remove only that boundary, and prove absence.

## Memory card and retrieval

~~~text
BOUNDARY: host, shell, UID, cwd, filesystem, repo, HEAD, branch
STATE:    working tree -> index -> objects/refs -> remote
READ:     status, ordinary diff, cached diff, history, ignore rule
CHANGE:   one path, one prediction, one bounded mechanism
SECRET:   ignore prevents some adds; exposure requires revoke/rotate
UNDO:     restore local state; reset private refs; revert shared history
VERIFY:   exact test + consumer outcome + integrity
CLEAN:    exact owned scope, refusal on surprise, prove absence
~~~

Retrieval prompts:

1. `MM app.conf`: which three versions exist and which diff shows each transition?
2. A token was pushed: what happens before history rewriting?
3. Local passes but CI says permission denied: which committed and environment signals do you compare?
4. Why is clean status weaker than "this repository contains no secret"?
5. When is revert normally safer than reset?
6. What evidence makes automated cleanup bounded?
7. What does a signed commit prove and not prove?
8. How does a Git source rollback differ from operational rollback?

Answer tomorrow without looking. Reading builds recognition; retrieval and original work build durable recall.

## Complete answers

### Decode `MM app.conf`

`HEAD` contains A. The index contains staged B, causing the left `M`. The worktree contains later C, causing the right `M`. `git diff --cached -- app.conf` shows A-to-B. `git diff -- app.conf` shows B-to-C. Neither alone reveals complete intent. Review both.

### Respond to a pushed token

Treat it as exposed. Do not repeat it. Notify credential and repository owners and revoke or rotate first. Scope refs, clones, forks, reviews, caches, artifacts, logs, and deployments; verify old credential rejection. Coordinate any rewrite, recognizing changed IDs and recontamination. Add runtime delivery, narrow ignores, scanning, least privilege, short lifetime, and review.

### Compare local and CI permission failure

Use the same full commit and entry point. Compare tracked filename case, tree mode via `git ls-tree`, shebang, line endings and attributes, shell, directory, runner OS/filesystem, mount, checkout, tool versions, and ignored/generated inputs. Local `chmod +x` helps only when Git records it and the commit reaches CI.

### Explain clean status limits

Status answers a narrow comparison. Ignored files may exist; secrets can be in earlier commits, tags, stashes, reflogs, submodules, artifacts, or caches; a clean commit can still be wrong; external systems are outside Git.

### Choose revert versus reset

For published history, revert normally creates an auditable inverse without moving collaborators' ancestry. Reset moves a ref and may change index/worktree. Pushing rewritten refs disrupts consumers. Revert still needs schema, data, merge-parent, and operational verification.

### Bound cleanup

Require exact canonical root under an allowed parent, identity/ownership, sentinel, strict descriptor, no symlink/hard-link/special/cross-device/foreign item, bounded count/size, top-level allowlist, physical traversal, exact target, refusal on surprise, and absence proof. Document races.

### Explain signing

A verified signature can show that a trusted key signed an object under verifier policy. Trust also depends on key ownership, protection, revocation, configuration, and review. It does not prove code correctness, dependencies, intent, or authorized deployment.

### Separate source and operational rollback

Moving or reverting a Git ref changes source or desired state. Production may run another artifact; controllers may not reconcile; config and schemas differ; durable effects remain. Track commit to artifact digest to promotion to runtime revision, then verify the user operation and integrity.

### Guided lab interpretation

`MM service.conf` means staged timeout change and later worktree change differ. `notes.txt` is untracked. `.env.local` and `scratch.log` are ignored fixtures. No remote exists and `HEAD` stays at baseline. Inspect each state, then use selective bounded recovery.

## Product-company interview

**Question:** A deployment repository has local edits, a release commit was pushed, CI passed, and production errors rose. Another engineer wants to force-push the branch back and rerun. What do you do?

**Strong answer:**

"I separate repository, pipeline, artifact, runtime, and user state. I establish ownership and freeze uncontrolled promotion. I record impact, recovery target, artifact digest, release commit, pipeline inputs, environment, and one affected path. Locally I identify canonical worktree, `HEAD`, branch, status, and owners without mutation.

"A force push changes a ref; it may not change artifact, data, config, or controller, and can destroy collaboration context. I compare healthy/current artifacts, validate config/schema compatibility, and trace the first abnormal boundary. If evidence supports release causality and rollback compatibility, I request a bounded canary mechanism with success/abort thresholds, integrity checks, and rollback-of-rollback. On shared history I prefer auditable revert unless owners coordinate exceptional rewrite.

"I verify the customer operation, objectives, data correctness, retry/queue behavior, dependencies, and healthy cohorts. I preserve unrelated edits through owner-approved mechanisms. Credential exposure triggers rotation/revocation separate from Git cleanup. After restoration, I improve provenance, gates, secret controls, rollback rehearsal, and user-journey checks."

This is senior because it does not confuse a source ref with deployed reality. It protects work, history, data, and service; uses a bounded authorized action; and verifies the consumer.

**Weak answer:** "Reset hard, force push the old commit, delete dirty files, and rerun because the deployment caused it."

It is weak because timing is not mechanism. It can erase local/shared work, may not change production, ignores compatibility and secrets, and has no prediction, approval, canary, abort, integrity, or user verification.

**When is force-with-lease acceptable?** It reduces one overwrite risk when rewriting an explicitly owned branch under policy with an exact expected remote ref. It still rewrites identities and affects consumers. Coordinate and preserve recovery refs.

**How do you prove CI built intended source?** Record full commit/ref resolution, submodule or large-file state, generated inputs, lockfiles, runner image, and artifact digest. Promotion must use that same immutable digest.

**How do you bisect a flaky failure?** Make classification reliable, repeat with a declared rule, record skipped commits, and control external inputs. Bisect finds a transition under the test; it does not explain mechanism.

**Merge or rebase?** Merge preserves ancestry and shared IDs. Rebase creates a new series useful for private review. Choose from collaboration, audit, release, and policy needs - not aesthetics.

## Independent transfer and rubric

Use `ASM-0012` and only the lab's `transfer` case from clean state. Do not read another learner's work or seek a model answer. The learner README exposes commands and boundaries but no diagnosis or recovery plan for transfer.

Submit:

1. sanitized safety card with environment, UID, lab boundary, forbidden operations, abort, recovery, and cleanup;
2. baseline and transfer status with every path classified across `HEAD`, index, worktree, untracked, and ignored state;
3. ordinary and cached diff interpretations with proof limits;
4. path-by-path ownership and intent decisions, including what a real repository might preserve;
5. selective-recovery prediction written before `recover`;
6. operation verification and limitations;
7. cleanup plus following clean check;
8. production transfer covering remote policy, secrets, rollback, observability, integrity, and cost.

The reviewer scores boundary safety, Git-state accuracy, evidence/proof limits, recovery/verification, and independent production transfer - four points each. Publication, guided answers, or verifier pass never award mastery.

## References and review

Primary references:

- `REF-0025`: GNU Bash Reference Manual for parsing, quoting, expansion, redirection, status, traps, and options.
- `REF-0026`: Microsoft guidance for Windows and WSL filesystem boundaries.
- `REF-0027`: official `git-status` documentation.
- `REF-0028`: official `git-diff` documentation.
- `REF-0029`: official `git-restore` documentation.
- `REF-0030`: official `git-reset` documentation and reset/revert distinctions.
- `REF-0031`: official `gitignore` documentation.
- `REF-0032`: GitHub guidance for sensitive-data exposure and coordinated history cleanup.

Review sources at version boundaries before changing shared workflows. Git behavior also depends on installed version, configuration, attributes, hooks, object format, filesystem, and hosting policy.

This substantive draft was reviewed on 2026-08-02. Review again by 2026-11-02 or sooner if lab contract, Ubuntu/WSL support, Git guidance, schemas, or primary documentation changes.
