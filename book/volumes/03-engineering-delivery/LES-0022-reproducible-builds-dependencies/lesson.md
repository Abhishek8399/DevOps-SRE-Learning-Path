---
{
  "schemaVersion": 1,
  "kind": "lesson",
  "id": "LES-0022",
  "aliases": ["V03-L07", "reproducible-builds-dependencies"],
  "curriculumIds": ["BLD-001"],
  "slug": "reproducible-builds-dependencies",
  "route": "/book/engineering/reproducible-builds-dependencies",
  "order": 7,
  "volume": "03-engineering-delivery",
  "title": "Reproducible builds and dependencies: make artifact identity explainable",
  "summary": "Learn to treat a build as a controlled transformation rather than a hopeful command: close the input set, lock and verify dependencies, constrain build context, normalize time, path, locale, order, ownership, and randomness, design truthful cache keys, compare artifact bytes, connect SBOM and provenance subjects, diagnose nondeterminism and stale reuse, and promote only artifacts whose origin and postconditions are proved.",
  "domain": "engineering",
  "level": {"from": "foundation", "to": "advanced"},
  "estimatedMinutes": 540,
  "prerequisiteLessonIds": ["LES-0009", "LES-0021"],
  "prerequisiteCurriculumIds": ["SCM-001", "AUT-005"],
  "testedEnvironments": [
    {
      "platform": "Windows Subsystem for Linux (WSL 2) Ubuntu",
      "version": "Ubuntu 24.04 LTS, Bash 5.2.21, Python 3.12.3",
      "support": "required",
      "notes": "The required offline lab runs as UID 1000 in the tested environment, refuses UID 0, installs nothing, opens no socket, and creates only exact guarded current-user state under /tmp."
    },
    {
      "platform": "Ubuntu Linux",
      "version": "Ubuntu 24.04 LTS with Bash 5+ and Python 3 standard library",
      "support": "supported",
      "notes": "The lab is designed for the same non-root tools and /tmp semantics on native Ubuntu, but the complete verifier was executed under WSL 2."
    },
    {
      "platform": "CI builders, container builders, package ecosystems, Kubernetes delivery platforms, private cloud, and public cloud",
      "version": "tool-neutral concepts",
      "support": "concept-only",
      "notes": "The chapter transfers the evidence model, but it does not download dependencies, run Docker or BuildKit, produce a real language package, sign an attestation, publish an artifact, or claim a supply-chain maturity level."
    }
  ],
  "targetRoles": ["site-reliability-engineer", "devops-engineer", "platform-engineer", "production-engineer", "release-engineer", "build-engineer", "software-supply-chain-engineer", "security-engineer"],
  "learningObjectives": [
    "Define repeatable, deterministic, reproducible, isolated, hermetic, and verifiable builds precisely enough to state which claim current evidence supports.",
    "Model a build as artifact bytes produced from an explicit closure of source, dependency, toolchain, configuration, environment, context, and permitted external inputs.",
    "Distinguish a dependency manifest, resolver decision, lock record, fetched artifact, checksum, signature, installed tree, and runtime module without assuming one proves another.",
    "Diagnose nondeterminism caused by time, timezone, locale, path, file order, archive metadata, randomness, concurrency, host discovery, generated identifiers, and mutable remote state.",
    "Design complete cache keys and safe restore rules, recognize stale or poisoned reuse, and explain why a cache hit is evidence of reuse rather than proof of correctness.",
    "Compare artifact identities at the correct boundary, localize byte differences, separate expected platform variance from accidental variance, and verify consumer readback before promotion.",
    "Connect artifact digests, SBOM subjects and components, provenance subjects and materials, signatures, identities, policy, and independent rebuild evidence without overstating any control.",
    "Operate builds with least privilege, bounded resources, secret-safe context, immutable promotion, rollback, observability, incident classification, and product-company-level communication."
  ],
  "productionSignals": [
    "The same source revision produces different artifact digests on two nominally identical CI runners.",
    "A build becomes green only when a warm cache is available, or becomes different only after the cache is cleared.",
    "A dependency name and version are unchanged while the downloaded or installed artifact checksum differs from the lock or approved mirror.",
    "A container build unexpectedly transfers gigabytes of context, includes a local secret, or changes when an unrelated workspace file changes.",
    "A release manifest points to one digest while its SBOM or provenance statement names another subject digest.",
    "Two archives contain semantically identical files but differ in timestamps, ownership, path order, compression headers, permissions, or generated metadata.",
    "A candidate artifact matches a previous expected hash even though the current dependency tree or build context fails integrity checks.",
    "A rebuild uses a mutable tag, branch, package index response, base image label, plugin channel, or unpinned toolchain and cannot reconstruct the resolved bytes later.",
    "Parallel builders race while publishing the same version, and a later successful writer hides which artifact consumers received.",
    "Build duration, cache storage, context transfer, dependency fan-out, artifact size, SBOM size, or signing latency grows faster than completed releases."
  ],
  "diagrams": [
    {
      "id": "LES-0022-DIA-001",
      "title": "A build is a transformation with an explicit input closure",
      "direction": "left-to-right",
      "boundaries": ["declared source", "resolved dependencies", "builder and toolchain", "configuration and environment", "build context", "artifact bytes", "consumer verification"],
      "evidencePoints": ["revision and source digest", "lock and artifact integrity", "builder image and compiler digest", "flags time locale path randomness", "allowlisted path manifest", "artifact digest and structure", "schema signature policy and readback"],
      "textAlternative": "Source, dependency bytes, builder identity, configuration, environment, and the exact context enter one controlled transformation. The output is artifact bytes with a digest, and a consumer verifies both identity and the promised behavior before promotion."
    },
    {
      "id": "LES-0022-DIA-002",
      "title": "Dependency assurance is a chain, not one lockfile",
      "direction": "top-to-bottom",
      "boundaries": ["human manifest", "resolver", "lock graph", "registry or mirror object", "integrity verification", "installed tree", "runtime loading"],
      "evidencePoints": ["allowed ranges", "algorithm and platform", "exact versions and sources", "immutable object identity", "checksum or trusted signature", "files hooks and native variants", "loaded path and version"],
      "textAlternative": "A manifest permits versions, a resolver chooses a graph, a lock records that graph, a registry or mirror supplies bytes, integrity validates those bytes, installation creates a tree, and the runtime loads a particular object. Evidence must cross every boundary."
    },
    {
      "id": "LES-0022-DIA-003",
      "title": "Cache correctness depends on complete identity",
      "direction": "cyclic",
      "boundaries": ["canonical inputs", "cache-key function", "shared cache namespace", "candidate entry", "entry validation", "build or reuse", "artifact verification"],
      "evidencePoints": ["source lock dependency context toolchain flags platform", "key version and encoding", "writer identity and tenant scope", "metadata subject and creation policy", "expected key and integrity", "hit miss and reason", "two-build digest and consumer readback"],
      "textAlternative": "Canonical build inputs are encoded into a versioned cache key. A scoped cache returns a candidate entry, but the caller validates its identity and policy before reuse. Whether reused or freshly built, the artifact is verified independently."
    },
    {
      "id": "LES-0022-DIA-004",
      "title": "Artifact, SBOM, provenance, and signature answer different questions",
      "direction": "hierarchical",
      "boundaries": ["artifact digest", "SBOM subject and components", "provenance subject and materials", "attestation signature", "verifier identity policy", "promotion decision"],
      "evidencePoints": ["which bytes", "what is reported inside", "how and from what it was reportedly built", "which key signed which statement", "whether signer and claims are trusted", "whether release policy is satisfied"],
      "textAlternative": "The artifact digest identifies bytes. An SBOM inventories reported components, provenance describes reported build inputs and process, a signature binds statement bytes to a key, and verifier policy decides whether that identity and evidence authorize promotion."
    },
    {
      "id": "LES-0022-DIA-005",
      "title": "A reproducibility incident is localized from output back to first variance",
      "direction": "left-to-right",
      "boundaries": ["consumer-visible release", "published artifact", "packaging metadata", "build output tree", "compiler or generator", "dependency and context", "builder environment", "source and instructions"],
      "evidencePoints": ["impact and selected digest", "registry object and promotion log", "archive order owner time compression", "file-level hashes", "flags seed path locale concurrency", "lock integrity and context manifest", "image kernel architecture environment", "revision dirty state submodules"],
      "textAlternative": "Start with the digest consumers received, preserve the published object, unpack and compare metadata and files, then move backward through generator flags, dependencies, context, environment, source, and instructions until the first differing input or behavior is found."
    }
  ],
  "commands": [
    {
      "id": "LES-0022-CMD-001",
      "question": "Which kernel, architecture, shell, Python runtime, identity, and locale define this local build observation?",
      "risk": "read-only",
      "command": "uname -srmo; getconf LONG_BIT; bash --version | sed -n '1p'; python3 --version; id; locale | grep -E '^(LANG|LC_ALL)='",
      "runFrom": "The same normal-user Ubuntu shell that will run the build or lab",
      "expectedBranches": [
        {"when": "Runtime, architecture, identity, and locale match the supported builder contract", "meaning": "The observed execution baseline is consistent with the reviewed environment.", "nextEvidence": "Record source state, dependency identities, toolchain digest, and build flags."},
        {"when": "Any value differs or the process is UID 0", "meaning": "An environment or privilege dimension changed before the build began.", "nextEvidence": "Stop and select the reviewed non-root builder; do not hide the difference with a broad compatibility claim."}
      ],
      "proves": "Point-in-time values reported by this process and host for the displayed fields.",
      "doesNotProve": "Builder image integrity, dependency closure, hermeticity, artifact reproducibility, or production equivalence."
    },
    {
      "id": "LES-0022-CMD-002",
      "question": "Which source revision and workspace changes are actually entering the build?",
      "risk": "read-only",
      "command": "git rev-parse --verify HEAD; git status --short; git submodule status --recursive",
      "runFrom": "The reviewed Git worktree root",
      "expectedBranches": [
        {"when": "A full revision is printed, status is empty, and submodules are at expected revisions", "meaning": "The sampled source state has a stable revision and no displayed worktree drift.", "nextEvidence": "Hash the exported source or context; Git cleanliness does not cover ignored files or external inputs."},
        {"when": "Modified, untracked, conflicted, or unexpected submodule markers appear", "meaning": "The build input is not the claimed clean revision.", "nextEvidence": "Preserve the status and diff, then use a reviewed clean checkout or deliberately include and review the changes."}
      ],
      "proves": "The current Git revision, displayed tracked/untracked status, and recorded submodule state.",
      "doesNotProve": "Ignored-file absence, remote branch identity, signed history, generated context bytes, or dependency integrity."
    },
    {
      "id": "LES-0022-CMD-003",
      "question": "Do the exact local dependency artifacts match their reviewed integrity file?",
      "risk": "read-only",
      "command": "sha256sum --check dependencies.sha256",
      "runFrom": "A reviewed offline dependency bundle containing `dependencies.sha256` and its named files",
      "expectedBranches": [
        {"when": "Every named object reports OK", "meaning": "Those current bytes match the SHA-256 values recorded in this integrity file.", "nextEvidence": "Validate the lock graph, source of the integrity record, platform variant, install hooks, and loaded runtime path."},
        {"when": "FAILED, missing, malformed, or an unexpected file appears", "meaning": "The dependency closure or integrity evidence is incomplete or different.", "nextEvidence": "Fail closed, preserve hashes and origin metadata, and restore only from an approved immutable source or review an intentional update."}
      ],
      "proves": "Byte equality between named local files and recorded SHA-256 values.",
      "doesNotProve": "Who authorized the hashes, package safety, signature trust, complete transitive coverage, or runtime loading."
    },
    {
      "id": "LES-0022-CMD-004",
      "question": "What exact regular-file set and per-file hashes form this sampled build context?",
      "risk": "sampled-read-only",
      "command": "find -P . -xdev -type f -printf '%P\\0' | LC_ALL=C sort -z | xargs -0 -r sha256sum",
      "runFrom": "A reviewed small local context; bound output size before using it on a large tree",
      "expectedBranches": [
        {"when": "Only allowlisted paths appear in stable byte order", "meaning": "The sampled regular-file context is explicit enough to compare with another run.", "nextEvidence": "Also record file mode, symlink policy, ignored paths, context-root identity, and the framed aggregate algorithm."},
        {"when": "Secrets, caches, generated files, local notes, or unexplained paths appear", "meaning": "The build context is wider than the intended source interface.", "nextEvidence": "Stop transmission or build, preserve the path list, rotate any exposed secret, and narrow context through reviewed allowlists or ignore rules."}
      ],
      "proves": "Names and SHA-256 values for sampled regular files on one filesystem at traversal time.",
      "doesNotProve": "A race-free snapshot, directory metadata, symlink targets, secret absence in file content, or remote-builder receipt."
    },
    {
      "id": "LES-0022-CMD-005",
      "question": "Which volatile environment values are explicitly controlled without dumping secrets?",
      "risk": "read-only",
      "command": "printf 'TZ=%q\\nLC_ALL=%q\\nLANG=%q\\nSOURCE_DATE_EPOCH=%q\\nPYTHONHASHSEED=%q\\n' \"${TZ-}\" \"${LC_ALL-}\" \"${LANG-}\" \"${SOURCE_DATE_EPOCH-}\" \"${PYTHONHASHSEED-}\"",
      "runFrom": "The build process boundary before starting the toolchain",
      "expectedBranches": [
        {"when": "Values match the reviewed build contract", "meaning": "These five environment dimensions are explicit for this invocation.", "nextEvidence": "Record the complete allowlisted environment contract and reject inherited variables outside it."},
        {"when": "Values are absent, host-dependent, or differ across runners", "meaning": "Time, locale, timezone, or language-level ordering can vary.", "nextEvidence": "Set values through the reviewed builder definition and run two clean builds; never print the whole environment because it may contain secrets."}
      ],
      "proves": "Only the displayed allowlisted variable values for this shell.",
      "doesNotProve": "That tools honor them, that no other variable matters, or that logs and process environments contain no secret."
    },
    {
      "id": "LES-0022-CMD-006",
      "question": "Are two candidate artifact files byte-for-byte identical?",
      "risk": "read-only",
      "command": "sha256sum artifact-a.bin artifact-b.bin; cmp -s -- artifact-a.bin artifact-b.bin; printf 'cmp_status=%s\\n' \"$?\"",
      "runFrom": "A directory containing two preserved candidate artifacts with known origin",
      "expectedBranches": [
        {"when": "SHA-256 values match and cmp_status is 0", "meaning": "The two sampled files are byte-identical.", "nextEvidence": "Verify artifact type, expected digest, source/material provenance, signature policy, and consumer readback."},
        {"when": "Digests differ or cmp_status is nonzero", "meaning": "The files differ at the byte boundary.", "nextEvidence": "Preserve both, unpack with non-mutating tooling, compare structure and metadata, and move backward to the first varying input."}
      ],
      "proves": "Byte identity or difference for these two files at comparison time.",
      "doesNotProve": "Correctness, safety, authorization, origin, semantic equivalence, or why bytes differ."
    },
    {
      "id": "LES-0022-CMD-007",
      "question": "Which archive metadata can explain a digest difference?",
      "risk": "read-only",
      "command": "tar --full-time --numeric-owner -tvf artifact.tar",
      "runFrom": "A directory containing a reviewed local tar artifact; never extract an untrusted archive into a valuable path",
      "expectedBranches": [
        {"when": "Path order, timestamps, numeric owners, modes, and sizes match the canonical policy", "meaning": "The listed tar metadata does not show variance for those fields.", "nextEvidence": "Compare raw headers, compression wrapper, extended attributes, file bytes, and generator version."},
        {"when": "Time, owner, group, mode, order, path, or size differs", "meaning": "Packaging metadata is a concrete candidate for artifact variance.", "nextEvidence": "Normalize it at archive creation, rebuild twice from clean inputs, and verify no semantic metadata was erased accidentally."}
      ],
      "proves": "Metadata and paths that this tar implementation reports for one archive.",
      "doesNotProve": "Safe extraction, absence of malicious paths, file-content equality, compression determinism, or signature validity."
    },
    {
      "id": "LES-0022-CMD-008",
      "question": "Which tracked, untracked, ignored, or generated paths could enter a Git-based build context?",
      "risk": "read-only",
      "command": "git ls-files -co --exclude-standard -z | LC_ALL=C sort -z | tr '\\0' '\\n'",
      "runFrom": "A reviewed small Git worktree where bounded path output is safe",
      "expectedBranches": [
        {"when": "The list matches the reviewed context allowlist", "meaning": "Tracked and non-ignored untracked paths are understood for this snapshot.", "nextEvidence": "Compare with builder-specific ignore evaluation and the context digest actually received by the builder."},
        {"when": "A secret, build output, editor file, cache, or unrelated directory appears", "meaning": "Workspace contents can change context, cache keys, confidentiality, or build behavior.", "nextEvidence": "Stop the build transfer, rotate exposed credentials where needed, and narrow the context at its source."}
      ],
      "proves": "Paths selected by this Git query at one moment.",
      "doesNotProve": "Docker ignore semantics, ignored-file absence, path content safety, a race-free snapshot, or remote receipt."
    },
    {
      "id": "LES-0022-CMD-009",
      "question": "Is the dependency lock syntactically valid JSON before semantic checks?",
      "risk": "read-only",
      "command": "python3 -m json.tool deps.lock.json >/dev/null; printf 'json_status=%s\\n' \"$?\"",
      "runFrom": "A reviewed project containing `deps.lock.json`",
      "expectedBranches": [
        {"when": "json_status is 0", "meaning": "The file is syntactically valid JSON for this parser.", "nextEvidence": "Validate schema, duplicate-key policy, lock format version, complete graph, source locations, integrity values, and manifest consistency."},
        {"when": "The parser returns nonzero", "meaning": "The lock cannot be interpreted as the expected JSON representation.", "nextEvidence": "Fail before dependency access, preserve the parse error, and repair through the ecosystem's reviewed lock generator."}
      ],
      "proves": "JSON syntax acceptance by this Python runtime.",
      "doesNotProve": "Schema validity, unique keys, dependency completeness, artifact availability, integrity, or authorization."
    },
    {
      "id": "LES-0022-CMD-010",
      "question": "Does a CycloneDX-style SBOM subject digest identify the artifact bytes being considered?",
      "risk": "read-only",
      "command": "python3 -c 'import hashlib,json,pathlib,sys; a=pathlib.Path(sys.argv[1]).read_bytes(); b=json.loads(pathlib.Path(sys.argv[2]).read_text()); print(hashlib.sha256(a).hexdigest()); print(b[\"metadata\"][\"component\"][\"hashes\"][0][\"content\"])' artifact.json bom.json",
      "runFrom": "A reviewed local artifact and SBOM copy; adapt only after validating the SBOM schema and hash algorithm",
      "expectedBranches": [
        {"when": "Both displayed digests match", "meaning": "The selected SBOM subject field names these artifact bytes.", "nextEvidence": "Validate SBOM schema, generator, component completeness, dependency relationships, signature, and policy."},
        {"when": "Digests differ or fields are absent", "meaning": "The SBOM is detached, stale, malformed, or refers to another artifact.", "nextEvidence": "Refuse the pair, preserve both objects, resolve generation or association, and never edit the subject digest by hand."}
      ],
      "proves": "Equality or difference between one computed artifact digest and one selected SBOM field.",
      "doesNotProve": "Component completeness, vulnerability status, license compliance, SBOM authenticity, or safe artifact behavior."
    },
    {
      "id": "LES-0022-CMD-011",
      "question": "Does a SLSA-style provenance subject name the candidate artifact?",
      "risk": "read-only",
      "command": "python3 -c 'import hashlib,json,pathlib,sys; a=pathlib.Path(sys.argv[1]).read_bytes(); p=json.loads(pathlib.Path(sys.argv[2]).read_text()); print(hashlib.sha256(a).hexdigest()); print(p[\"subject\"][0][\"digest\"][\"sha256\"])' artifact.json provenance.json",
      "runFrom": "A reviewed local artifact and provenance statement before cryptographic verification",
      "expectedBranches": [
        {"when": "The subject digest matches", "meaning": "The statement is associated with these candidate bytes at the selected field.", "nextEvidence": "Verify statement schema, signature, signer identity, trust root, materials, builder policy, freshness, and promotion rule."},
        {"when": "The subject differs, is duplicated ambiguously, or is absent", "meaning": "The statement cannot support this artifact decision.", "nextEvidence": "Refuse promotion, preserve the mismatch, and obtain provenance from the trusted build path."}
      ],
      "proves": "Digest association between one local artifact and one provenance subject field.",
      "doesNotProve": "That the statement is signed, truthful, complete, produced by a trusted builder, or sufficient for any SLSA level."
    },
    {
      "id": "LES-0022-CMD-012",
      "question": "Does the complete offline lesson lifecycle preserve isolation, refusal behavior, and exact cleanup?",
      "risk": "mutating-bounded",
      "command": "bash verify.sh",
      "runFrom": "`book/labs/LES-0022-reproducible-builds-dependencies` in a normal-user Ubuntu 24.04 shell",
      "expectedBranches": [
        {"when": "verification_passed=true and cleanup_proven=true appear with final state absent", "meaning": "Both deterministic modeled cases and the checked refusal/cleanup controls passed in this environment.", "nextEvidence": "Submit independent reasoning for human review and transfer the controls to a real builder without copying model claims."},
        {"when": "The verifier stops or any guard refuses", "meaning": "A precondition, lifecycle invariant, or expected safety behavior is not proved.", "nextEvidence": "Preserve the first error, run `bash lab.sh check`, inspect exact state, and do not bypass ownership or cleanup guards."}
      ],
      "proves": "The tested local model, lifecycle, refusal cases, answer isolation, interruption resume, and final cleanup behaved as encoded.",
      "doesNotProve": "The learner's diagnosis, a real package build, network isolation certification, trusted provenance, SBOM completeness, or production mastery.",
      "cleanup": "The verifier invokes only `bash lab.sh cleanup`, restores its exact test mutations, removes exact external canaries it created, and requires final `state=absent`; if interrupted, rerun the same verifier or `bash lab.sh cleanup` without manual recursive removal."
    }
  ],
  "labs": [
    {
      "id": "LES-0022-LAB-001",
      "title": "Find and remove volatile build inputs before trusting artifact hashes",
      "mode": "guided",
      "environment": "Normal-user Ubuntu 24.04 LTS or WSL 2 Ubuntu 24.04 with Bash 5+ and Python 3 standard library",
      "timeMinutes": 90,
      "privilege": "Non-root only; sudo and UID 0 are refused",
      "network": "None; deterministic in-memory source, dependency, cache, artifact, SBOM, and provenance records",
      "changes": ["One exact current-UID descriptor under /tmp", "One random mode-0700 lesson root under /tmp", "Small exact-name lifecycle records protected by mode and link-count checks"],
      "abortConditions": ["Any ownership, mode, canonical-path, link-count, sentinel, model-byte, descriptor, allowlist, lock, or lifecycle check refuses", "An unexpected file, symlink, hard link, candidate root, or model change appears", "A command would require root, network, package installation, a credential, Docker, or cloud access", "Two builds differ and the first variance has not been localized"],
      "recovery": "Explain which uncontrolled fields changed, normalize only fields that are not part of artifact meaning, rebuild twice from the reviewed input closure, connect SBOM and provenance subject digests, verify consumer readback, then use exact controller cleanup.",
      "cleanupProof": "The controller writes a validated resumable cleanup marker, removes exact existing allowlisted files, removes the exact empty registered root and descriptor, rejects orphans, and proves state=absent.",
      "path": "book/labs/LES-0022-reproducible-builds-dependencies"
    },
    {
      "id": "LES-0022-LAB-002",
      "title": "Independent stale-cache and dependency-drift investigation",
      "mode": "independent",
      "environment": "A clean normal-user Ubuntu 24.04 shell using the same offline guarded lab",
      "timeMinutes": 120,
      "privilege": "No sudo, root, daemon configuration, package install, credentials, registry, cloud, or production write",
      "network": "None; raw scenario first and deterministic derived views only after learner predictions",
      "changes": ["The same guarded /tmp state boundary", "A neutral case identifier and modeled lifecycle records", "Learner response stored outside the random lab root and never read by the verifier"],
      "abortConditions": ["Scenario was not captured before derived views", "A prior case, cleanup marker, or unknown artifact exists", "Current dependency integrity or context allowlist is invalid and promotion is proposed", "Any proposed recovery clears broad caches, changes a lock silently, follows a link, or weakens a guard"],
      "recovery": "Classify the candidate artifact, current input closure, lock integrity, context, cache identity, SBOM, provenance, and promotion permission separately; quarantine only the suspect entry, restore reviewed local dependency bytes, use a complete key, perform two clean modeled builds, verify the original operation, and clean exactly.",
      "cleanupProof": "The normal-user verifier covers dry-run, both cases, idempotent cleanup, unexpected artifact, model tamper, symlink canary preservation, descriptor redirection, orphan refusal, answer isolation, simulated cleanup interruption, resume, and final absence. Root refusal remains a separate reviewer check.",
      "path": "book/labs/LES-0022-reproducible-builds-dependencies"
    }
  ],
  "incidents": [
    {
      "id": "LES-0022-INC-001",
      "signal": "Two release jobs build the same Git revision and lockfile but publish different SHA-256 digests; one runner is warm and one is new.",
      "firstThought": "The revision and lock filename are only part of the input closure. Preserve both artifacts and builders, separate warm-cache behavior from clean-build behavior, and locate the first differing bytes before retrying or promoting either artifact.",
      "safePath": "Freeze promotion, record source export digest, dirty state, submodules, dependency artifact hashes, toolchain image digest, architecture, flags, environment allowlist, build context manifest, cache key and entry identity, timestamps, paths, archive metadata, artifact digests, SBOM, provenance, and consumer selection; rebuild twice in reviewed clean isolated builders, compare structurally, correct the first uncontrolled input, canary, and verify the release digest consumers receive.",
      "trap": "Clearing every cache and rerunning until hashes match, choosing the artifact from the familiar runner, treating a green job as proof, or overwriting the version while consumers may already have fetched both variants."
    },
    {
      "id": "LES-0022-INC-002",
      "signal": "A candidate artifact matches last week's approved hash, but current dependency bytes fail the lock checksum and the build reports a cache hit.",
      "firstThought": "A matching old artifact can be genuine stale reuse while the current request is invalid. Artifact identity and current-input integrity are separate questions; a hit does not prove the current inputs would produce that artifact.",
      "safePath": "Stop promotion, preserve the candidate, failed dependency bytes, lock, resolver and mirror metadata, cache key and namespace, entry writer, artifact association, SBOM and provenance; quarantine only the suspect cache entry, determine whether the dependency changed or the wrong platform variant was selected, restore from an approved immutable object or review an intentional upgrade, rebuild twice with a complete versioned key, and verify subject digests, policy, consumer readback, and zero duplicate publication.",
      "trap": "Accepting the old known hash, updating the lock checksum to whatever arrived, disabling integrity checks, clearing a shared cache without scope, or signing a newly generated statement that merely repeats the stale artifact claim."
    }
  ],
  "assessmentIds": ["ASM-0049", "ASM-0050", "ASM-0051"],
  "referenceIds": ["REF-0129", "REF-0130", "REF-0131", "REF-0132", "REF-0133", "REF-0134", "REF-0135", "REF-0136"],
  "contentStatus": "substantive-draft",
  "masteryBoundary": "publication-does-not-award-mastery",
  "lastReviewed": "2026-08-02",
  "reviewAfter": "2027-02-02",
  "limitations": [
    "The verified lab is an offline Python standard-library model under WSL 2 Ubuntu 24.04. It does not compile application code, invoke a package manager, run Docker or BuildKit, fetch a base image, contact a registry, or publish an artifact.",
    "The lab's SBOM and provenance documents are compact conceptual records. They are unsigned, generated by the same local model, and prove no SLSA level, trusted identity, vulnerability state, license decision, or production policy.",
    "SHA-256 comparisons demonstrate byte identity for sampled files. They do not prove semantic correctness, authorization, absence of malicious content, collision impossibility under every threat model, or safe execution.",
    "The filesystem guards reduce accidental scope errors for the tested current user. They are not a formal defense against a malicious same-UID process or a compromised kernel and do not model hostile multi-tenant builders.",
    "Ecosystem examples explain npm, pip, container, archive, and provenance concepts, but every real tool version, platform resolver, native dependency, signature format, and registry policy requires its own tested contract.",
    "Publishing this chapter or passing its deterministic verifier does not award mastery. Independent diagnosis, production transfer, and human review remain required."
  ]
}
---

# Reproducible builds and dependencies: make artifact identity explainable

## What you see and first thought

A release pipeline says `success`. The source revision is correct. The lockfile did not change. Yet the artifact from runner A has digest `aaa...` and runner B has `bbb...`.

The beginner reaction is usually, "The build is flaky. Clear the cache and rerun." The senior reaction is different:

> Two output identities mean at least one uncontrolled input or nondeterministic behavior exists. Preserve both outputs and both build records before changing anything.

That sentence is the heart of this chapter. A build is not a magical command called `npm run build`, `go build`, `mvn package`, `docker build`, or `make`. It is a transformation. Source bytes, dependency bytes, toolchain bytes, flags, environment, filesystem context, time, path, order, randomness, architecture, and allowed external responses enter the transformation. Artifact bytes come out. If an input can influence the output, that input belongs in the contract whether the team documented it or not.

When you see a mismatch, do not immediately erase the evidence by rebuilding in place. Preserve:

- both exact artifact objects and digests;
- immutable source revision plus exported-source digest;
- dirty and ignored workspace state;
- lockfile, resolver, package-manager, registry, mirror, and downloaded-object identities;
- toolchain and builder image digests, not only friendly tags;
- architecture, operating system, kernel interface where relevant, and build flags;
- an allowlisted environment record with secrets excluded;
- context path manifest, per-file hashes, ignore rules, and context digest;
- cache key, key version, namespace, hit/miss decision, entry identity, writer, and creation policy;
- SBOM, provenance, signature envelope, verification result, and promotion log;
- which digest was exposed to consumers and whether multiple bytes were published under one version.

Now consider the opposite symptom. The candidate hash matches last week's approved artifact, but the current dependency checksum fails and the job says `cache hit`. A matching artifact does not rescue invalid current inputs. The cache may have returned old valid bytes without evaluating today's dependency or context. Ask two separate questions:

1. **What bytes is this candidate?** The artifact digest answers that.
2. **Did the current authorized input closure produce it under the current build operation?** Cache, provenance, builder, and operation evidence must answer that.

This distinction prevents an experienced-looking but dangerous shortcut: "We know this hash, so ship it." A known hash can be acceptable only if release policy intentionally permits reusing that immutable object and the operation proves it selected the approved object. It cannot be used to pretend a broken current build was healthy.

The practical first-response rule is:

```text
different bytes  -> preserve, localize the first variance, do not choose by familiarity
same bytes       -> identity matches; still verify origin, policy, and current operation
invalid inputs   -> refuse build or promotion even if a stale candidate looks familiar
unknown outcome  -> reconcile by immutable digest and operation identity before retry
```

## Terms before commands

The vocabulary matters because teams often use "reproducible" to mean five different things.

**Build** means a transformation from a declared input set to specified output artifacts using defined instructions and an execution environment. Compilation can be part of it, but copying, code generation, dependency installation, archive creation, container layering, signing, and manifest publication can also be build steps.

**Artifact** means a specified primary output whose identity matters to a consumer: a binary, library archive, package, container image manifest, filesystem image, chart package, generated bundle, or deployment descriptor. Logs and temporary directories are usually evidence, not the artifact, unless the contract explicitly says otherwise.

**Deterministic build behavior** means one fully specified input state leads to one output byte sequence. Determinism is a property of the transformation. It does not say another party possesses the inputs or can run the transformation.

**Repeatable build** usually means the same party can perform the build again under sufficiently controlled conditions and obtain the expected result. The word is useful, but you must state what was held constant and what equality was checked.

**Reproducible build** has a stronger, widely used meaning: given the same source, build environment, and build instructions, another party can recreate bit-for-bit identical specified artifacts. The author or distributor must define the relevant environment and artifact boundary. "It builds twice on my laptop" is valuable evidence, but it is not yet independent reproducibility.

**Hermetic build** means the build's inputs come only through declared channels and undeclared host or network state cannot influence it. People sometimes use hermetic to mean "no network," but network absence alone is insufficient. Reading `/usr/bin`, the home directory, wall clock, hostname, user database, or shared cache can still break hermeticity. Some controlled build systems permit declared immutable remote inputs; the essential property is that undeclared inputs cannot slip in.

**Isolated build** means other jobs, users, or host state are prevented from interfering beyond defined interfaces. Isolation is a mechanism. A container may improve isolation but still read mutable tags, time, network, or host-mounted directories. A VM may be isolated but not deterministic.

**Verifiable build** means evidence lets a verifier evaluate claims about the artifact. That may include artifact digest, signature, source revision, builder identity, materials, parameters, policy, and rebuild results. Verifiability is not automatically reproducibility. A trusted builder can sign provenance for a build that legitimately embeds a timestamp and therefore is not byte-reproducible.

**Dependency manifest** expresses requested or allowed dependencies, often with ranges or constraints. It describes intent, not necessarily the exact selected graph.

**Resolver** is the algorithm and implementation that turns constraints, available versions, platform markers, overrides, and policies into a selected graph. Resolver version and configuration can change the result.

**Lockfile** records a resolver result so later installs can reconstruct the selected graph more consistently. A useful lock records exact versions, sources, integrity, transitive relationships, and format semantics. It is evidence, not a force field. The installed bytes can still differ, a platform-specific artifact can be selected, an install hook can generate output, or a different tool can interpret the record differently.

**Checksum or digest** is a function of bytes. A SHA-256 value is a compact identity for practical comparison. It does not tell you who approved the bytes or whether they are safe.

**Signature** binds statement bytes to a cryptographic key. Trust requires more: who controls that key, how identity is established, whether the statement is fresh and authorized, whether key material is protected, and what policy accepts it.

**Build context** is the set of files and metadata a builder can access through its context interface. For Docker, for example, the positional context identifies the filesystem or other input made available to `COPY` and related instructions. An overly broad context is both a reproducibility problem and a confidentiality risk.

**Cache key** is a canonical identity for an equivalence class of reusable work. A complete key includes every build-affecting input for the cached result. A **restore key** or prefix match intentionally accepts a wider equivalence class and therefore needs stronger validation.

**SBOM**, a software bill of materials, is a structured inventory associated with a subject. It can report components, versions, hashes, relationships, suppliers, and licenses. It does not by itself prove the artifact was built from those components, that the list is complete, or that no component is vulnerable.

**Provenance** is verifiable information describing where, when, and how an artifact was produced. Build provenance commonly names artifact subjects and resolved materials. The statement must be associated with the artifact, validated, authenticated, and checked against policy. Self-authored unsigned JSON is a claim, not trust.

**Promotion** moves an already identified artifact into a more trusted or consumer-visible channel. A mature system promotes by immutable digest. It does not rebuild the same source separately for every environment and hope the outputs are equivalent.

## Architecture map

Think of the build as a chain of contracts:

```text
source revision + exported bytes
             |
manifest -> resolver -> lock graph -> dependency objects -> verified installed tree
             |                         |
             +-------------------------+
                         |
builder image/toolchain digest + flags + controlled environment
                         |
allowlisted build context + normalized metadata
                         |
                  build transformation
                         |
              specified artifact bytes
                         |
      digest + SBOM + provenance + signature
                         |
                  verifier policy
                         |
        immutable promotion -> consumer readback
```

Text alternative: a source snapshot and dependency intent pass through a resolver and integrity-checked dependency chain. Those bytes join a pinned toolchain, declared parameters, controlled environment, and exact context. The builder emits an artifact. Separate metadata describes inventory and origin, a verifier applies identity and policy, and promotion exposes the same digest to consumers.

There are three trust planes in this map.

The **data plane** contains source, dependencies, context, intermediate outputs, artifacts, SBOMs, and provenance statements. These are bytes that can be hashed, stored, copied, or corrupted.

The **control plane** chooses what may run and publish: source approvals, builder definitions, resolver policy, cache namespaces, signing identity, release gates, and rollback controls. A perfect artifact hash does not compensate for a control plane that lets any job overwrite a release tag.

The **evidence plane** records what happened: input digests, key decisions, builder identity, timestamps with defined meaning, cache events, artifact digest, attestation verification, promotion receipt, and consumer readback. Evidence must be bounded and secret-safe. Dumping the entire environment or build context into logs can leak credentials.

At product-company scale, ownership crosses teams:

- application teams own source intent and application-level tests;
- dependency or security teams may own approved mirrors and policy;
- platform teams own builder images, isolation, cache service, signing integration, and release storage;
- SRE or production engineering owns reliability signals, incident response, capacity, and safe recovery;
- release owners define which verified evidence permits promotion;
- consumers verify or resolve immutable identities at deployment time.

If no one owns a boundary, that boundary becomes a source of invisible variability. "CI owns the build" is too vague. Name the service, configuration repository, identity, state store, retention policy, and escalation owner.

## Request or state path

A trustworthy build operation follows a state path. Treat it like a production write, not a shell command.

### 1. Canonicalize intent

The request names an immutable source revision, target platform, build definition version, approved dependency policy, toolchain identity, feature flags, output types, and logical operation ID. Canonicalization must be unambiguous. String concatenation without framing can collide: `ab` + `c` and `a` + `bc` create the same bytes. Use a documented encoding with field names, lengths, or a canonical serialization.

### 2. Close source state

Export the source that the builder will see. Record submodules, generated source policy, large-file objects, patches, and whether ignored or untracked files may enter. A Git commit does not include ignored local credentials or a sibling directory accidentally placed in a recursive context.

### 3. Resolve and verify dependencies

The manifest states constraints. The lock records the selected graph. The fetch layer obtains exact artifacts from an approved source. Integrity checks compare fetched bytes with expected digests or trusted signatures. Installation is performed with reviewed scripts and platform selection. The system records what was actually installed, not merely what was requested.

Network access during the build makes closure harder. A package index can change, a mutable URL can return new bytes, a DNS or proxy path can differ, and an outage can block rebuild. Mature systems fetch into an approved immutable dependency store as a separate controlled operation, then build offline or through a narrowly declared mirror. "We use TLS" authenticates a transport endpoint under a trust chain; it does not pin the selected object or ensure long-term availability.

### 4. Select the builder

Use an immutable builder identity: image digest, VM image version plus checksum, Nix derivation, Bazel toolchain identity, or an equivalently controlled definition. Record compiler, linker, runtime, package manager, plugins, and relevant system libraries. A tag such as `ubuntu:24.04`, `node:22`, or `latest` is a human label that may resolve to different bytes later.

### 5. Construct exact context

List or hash the paths the builder can read. Apply ignore or allowlist rules before transfer. Reject secrets, previous outputs, caches, editor state, and unrelated repositories. Preserve path semantics intentionally: case sensitivity, Unicode normalization, symlinks, executable bits, and line endings can vary across Windows, WSL, macOS, and Linux.

### 6. Compute cache identities

A cache key must cover every input that can change the cached result: source digest, lock digest, dependency artifact digests, context digest, toolchain digest, target architecture and libc where relevant, build flags, generator versions, and cache schema version. Secret contents often must not be placed directly in a key or log; use a safe rotation identifier when secret change must invalidate a step.

### 7. Execute within budgets

Bound CPU, memory, disk, process count, open files, context bytes, output bytes, elapsed time, and network policy. Build isolation should give each operation private working state. Parallelism must not make output order nondeterministic. Randomized algorithms need a declared stable seed when randomness is not meaningful output.

### 8. Normalize only non-semantic variance

Use `SOURCE_DATE_EPOCH` or an ecosystem-supported source-derived time for build metadata that must be stable. Normalize timezone and locale. Sort paths. Set archive owner/group and permissions deliberately. Map workspace paths to stable prefixes where compilers embed debug paths. Do not erase metadata that consumers semantically require merely to make hashes match.

### 9. Verify artifacts

Build twice from clean, independent working directories. Avoid using the same warm cache as the only proof. Compare specified artifact bytes. If they differ, unpack non-destructively and localize the first variance. Run schema, signature, policy, and consumer tests. The build process exit code is necessary but not the postcondition.

### 10. Generate and bind supply-chain evidence

Generate an SBOM for the artifact subject. Generate provenance from the trusted build service, not from a later untrusted client that guesses what happened. Bind both to the artifact digest. Sign or otherwise authenticate attestations using the approved identity. Verify them before promotion.

### 11. Promote one immutable identity

Use compare-and-set or an immutable version policy so two concurrent jobs cannot publish different bytes under one release identity. Record the selected digest and operation. Deploy or distribute that exact object. Verify the consumer resolves the same digest.

### 12. Retain enough to rebuild and investigate

Retain source revision, build definition, dependency objects or immutable locators, lock, builder identity, artifacts, attestations, verification result, and logs for the defined support window. Reproducibility promises are weak if required inputs disappear tomorrow.

## Failure zoom

When two artifacts differ, move from bytes backward. Do not compare everything at once.

```text
consumer digest differs
        |
published object differs? ---- no ---> resolution or consumer-cache problem
        |
       yes
        v
archive/container metadata only? ---- yes ---> time, owner, order, compression, path
        |
       no
        v
one or more output files differ? ---- yes ---> generator/compiler/input boundary
        |
        v
dependency/context/toolchain differ? ---- yes ---> closure, lock, context, cache key
        |
        v
same declared inputs but behavior differs ---> concurrency, randomness, host discovery,
                                               undefined behavior, uninitialized data
```

Text alternative: first decide whether consumers resolved different published objects. If object bytes differ, distinguish package metadata from file-content variance. Trace changed files to the generator, then compare dependency, context, toolchain, and environment. If all declared inputs match, investigate undeclared state or nondeterministic behavior.

### Time and timezone

Build timestamps are a common first difference. They may appear in generated version files, archives, ZIP central directories, documentation, image configuration, compiler notes, or signatures. Replacing wall time with a source-derived epoch makes rebuilds stable when the timestamp is not consumer semantics. Timezone can change formatted strings even when the epoch is equal.

Do not blindly set every timestamp to zero. Some formats have minimum dates; some update systems use modification time; signatures and certificates have real temporal semantics. Define which timestamp represents source history, which represents build execution evidence, and which should not enter artifact bytes.

### Path and workspace identity

Compilers and generators can embed absolute paths in debug information, source maps, error catalogs, or generated files. Two runners with `/builds/team/service` and `/workspace/service` then differ. Use supported path-remapping flags or a stable workspace mount. Do not use search-and-replace over arbitrary binary output unless the format explicitly supports it.

### Locale and encoding

Sorting, case conversion, decimal formatting, month names, generated messages, and default file encoding can vary by locale. Set a build locale with tool support and encode outputs explicitly. `LC_ALL=C` gives byte-order behavior but may not meet Unicode needs; `C.UTF-8` often combines stable collation expectations with UTF-8, but availability and exact behavior remain platform facts to test.

### File and map order

Filesystem traversal order is not a contract. Hash maps can intentionally randomize order. Parallel workers can finish in different sequences. If order is not semantic, sort using a documented key before serializing or packaging. If order is semantic, make the source of order explicit and test it.

### Archive and container metadata

An archive includes more than file contents: path order, timestamps, user/group IDs, names, modes, link records, extended headers, and compression wrapper fields. A container image includes layers, configuration JSON, history, diff IDs, compression choices, annotations, and a manifest. Two images can yield the same runtime filesystem but different image digests. Define which artifact identity consumers use.

### Randomness and generated identifiers

UUIDs, random seeds, salts, temporary filenames, generated keys, and randomized optimization can enter bytes. Use deterministic seeds only where randomness is not a security requirement. Never make cryptographic keys deterministic just to achieve reproducibility. Separate security-sensitive key generation from reproducible artifact construction and bind public material through a reviewed process.

### Concurrency and undefined behavior

Parallel builds expose missing dependencies between steps, races in generators, nondeterministic link order, and writes to shared paths. Native compilation can also expose uninitialized memory or undefined behavior. Rebuilding serially is a useful discriminating test, not the final fix. Correct the dependency graph or code and restore bounded parallelism with tests.

### Cache behavior

Compare four runs: warm cache, cold cache, cache disabled for the suspect stage, and a second clean independent builder. If only warm output differs, inspect entry identity and restore rules. If only cold output differs, a cache may be hiding an undeclared dependency. Do not clear an entire shared cache during diagnosis; preserve the suspect entry and quarantine narrowly so you retain evidence and avoid fleet-wide load.

## Internals and state ownership

### Dependency state has several owners

The manifest belongs to source control. The resolver implementation and configuration belong to the package toolchain. The lock graph belongs to the repository but uses that resolver's semantics. The registry or mirror owns available object bytes. A cache stores copies. The installer creates a filesystem tree. The runtime loader selects a module from paths and environment.

This explains a common incident sentence: "The lockfile says 2.4.0, so dependency drift is impossible." The lock may name version 2.4.0 while:

- a mutable registry serves changed bytes;
- the checksum is absent, ignored, or updated silently;
- another architecture selects a different wheel or native package;
- an install script downloads or generates extra content;
- an override file changes resolution;
- the tool upgrades the lock format;
- a global or workspace package shadows the installed package;
- a runtime path loads another copy.

Pinning and integrity complement one another. A version pin narrows **which release identity** is selected. A checksum verifies **which bytes** arrived. A trusted signature can add **who vouched for a statement or object**. An immutable mirror adds **availability and retention**. Runtime introspection adds **what actually loaded**.

### Cache state needs an owner and namespace

A local cache, shared CI cache, BuildKit cache, package download cache, compiler cache, and remote action cache have different semantics. Define:

- who may write;
- who may read;
- tenant, repository, branch, and trust-domain isolation;
- key encoding and version;
- integrity on stored entries;
- maximum age and eviction;
- behavior after toolchain or policy change;
- whether untrusted pull requests can influence trusted builds;
- how a suspect entry is quarantined and inspected.

If an untrusted branch can write an entry later restored by a release job under a broad prefix, that is not merely a performance bug. It is a cache-poisoning path.

### The release repository is the artifact state owner

Once built, the artifact repository or registry becomes authoritative for distributed bytes. Tags are mutable references in many systems; digests are immutable content identities. Promotion should associate an approved logical release with one digest using a controlled atomic decision. Consumers should record or verify the resolved digest.

Never publish two different bytes under the same immutable version. If concurrent jobs race, one must win through a version precondition and the other must observe and reconcile. "Last writer wins" destroys incident clarity and can expose different consumers to different content.

### SBOM and provenance state are associated objects

An SBOM that names artifact digest A cannot be silently attached to artifact B. Provenance with subject A cannot authorize B. Association may be stored as registry referrers, signed bundles, release manifests, or another supported mechanism. The verifier must prevent mix-and-match attacks: a valid statement for one safe artifact must not be reusable for another.

### Reproducibility is scoped

A multi-platform release may legitimately have different artifacts for `linux/amd64`, `linux/arm64`, Windows, or different libc targets. Reproducibility means equal bytes within the fully specified target contract. The manifest list that joins platforms has its own identity and metadata. Do not compare an amd64 binary with arm64 and call the build nondeterministic.

## Evidence table

| Evidence | What it proves | What it does not prove | Safe next check |
|---|---|---|---|
| Full Git revision | Which commit object is named | Clean export, signed authorization, submodule or ignored-file state | Export and hash source; record status and submodules |
| Empty `git status --short` | No displayed tracked/untracked changes under current rules | Ignored files absent or builder context clean | Evaluate ignore/context rules and hash actual context |
| Lockfile digest | Identity of lockfile bytes | Correct semantics, complete graph, fetched-byte integrity | Validate format, tool version, manifest consistency, and artifacts |
| Dependency checksum OK | Current file bytes match recorded digest | Digest authorization, safety, complete transitive closure | Verify trusted source, graph coverage, signatures, and installed tree |
| Builder image digest | Which image object was selected | Runtime not modified, host isolation, correct flags | Record runtime identity and build attestation |
| Context path manifest | Which paths were sampled | Race-free snapshot or no secret in contents | Use immutable snapshot/allowlist and secret scanning policy |
| Cache hit | A key selected a stored entry | Key completeness, entry integrity, current-input validity | Compare key components and independently verify artifact |
| Matching artifact SHA-256 | Candidate files are byte-identical in practice | Correctness, origin, authorization, safe behavior | Verify expected digest, provenance, signature, policy, consumer readback |
| Matching unpacked tree | Selected paths/content match after extraction | Archive metadata or distribution identity match | Compare raw archives and normalized metadata |
| SBOM subject digest match | SBOM field refers to candidate bytes | Component completeness, authenticity, vulnerability status | Validate schema, signature, generator, components, and policy |
| Provenance subject match | Statement names candidate bytes | Truth, signature, trusted builder, sufficient materials | Verify envelope, identity, policy, materials, and builder controls |
| Valid signature | Statement bytes verify under a key | Key is authorized, statement is true, artifact is safe | Resolve identity/trust root and enforce release policy |
| Two clean independent matching builds | Declared process reproduced bytes twice | Universal future reproducibility or absence of shared compromise | Diversify builders and retain inputs/evidence |
| Job exit 0 | Process followed its success exit path | Artifact identity, promotion, or consumer acceptance | Verify artifact postconditions and release receipt |

Classify every incident note as observed fact, documented fact, calculation, inference, hypothesis, or unknown. "Cache corruption" is a hypothesis until you show a stored entry whose identity or contents violate the cache contract. "Digest A differs from digest B" is an observation. Keeping those labels separate stops incident chat from turning guesses into facts.

## Command decoders

### Decoder 1: establish the builder process

```bash
uname -srmo
getconf LONG_BIT
bash --version | sed -n '1p'
python3 --version
id
locale | grep -E '^(LANG|LC_ALL)='
```

`uname -srmo` asks the kernel for system name, release, machine, and operating-system label. `getconf LONG_BIT` reports the userspace word size through system configuration. The pipe sends Bash version text to `sed`; `-n` suppresses default output and `1p` prints only line one. `id` shows numeric and named identities and groups. The anchored regular expression selects only two locale variables instead of dumping every environment value.

Record exact output, not "Linux latest." Architecture changes dependency selection and binary output. UID 0 changes permissions and can hide missing least privilege. Locale changes sorting and formatting. This command does not hash the OS or builder image. Next, record the immutable builder image or VM definition and toolchain versions.

Trap: publishing the full environment as evidence. CI environments often contain tokens and endpoints. Use an allowlist and redact at the source.

### Decoder 2: establish source state

```bash
git rev-parse --verify HEAD
git status --short
git submodule status --recursive
```

`rev-parse --verify HEAD` resolves the current revision and refuses an invalid name. `status --short` gives a compact worktree/index view. An empty result is meaningful output: no displayed changes under Git's current ignore and configuration rules. `submodule status --recursive` shows nested revision relationships; prefixes can indicate uninitialized, different, or conflicted state.

Trap: assuming a clean status means the build context equals the commit. Ignored files, generated files outside Git, line-ending conversion, and sibling context paths can still enter. Hash the actual exported context.

### Decoder 3: verify dependency bytes

```bash
sha256sum --check dependencies.sha256
```

`--check` parses filename/digest records and hashes each named file. `OK` means current bytes match that record. `FAILED` is not an invitation to run with `--ignore-missing` or update the digest to whatever arrived. It is a stop signal.

Trap: a checksum stored beside a compromised package can be changed by the same attacker. Integrity needs a trusted review or signature path. Also check that the file covers every platform variant and transitive object required by this build.

### Decoder 4: inspect a bounded context

```bash
find -P . -xdev -type f -printf '%P\0' |
  LC_ALL=C sort -z |
  xargs -0 -r sha256sum
```

`-P` avoids following symlinks. `-xdev` stays on one filesystem. `-type f` selects regular files. `%P` prints a path relative to the starting point. NUL delimiters preserve spaces and newlines in filenames. `sort -z` sorts NUL records under byte-oriented collation. `xargs -0` reads them safely; `-r` avoids invoking `sha256sum` for an empty list.

This is a sampled diagnostic, not a production snapshot algorithm. Files can change between enumeration and hashing. Output can be enormous. Bound the tree and preserve sensitive filenames appropriately. A hardened builder should receive an immutable snapshot or content-addressed context.

### Decoder 5: inspect only volatile variables

```bash
printf 'TZ=%q\nLC_ALL=%q\nLANG=%q\nSOURCE_DATE_EPOCH=%q\nPYTHONHASHSEED=%q\n' \
  "${TZ-}" "${LC_ALL-}" "${LANG-}" "${SOURCE_DATE_EPOCH-}" "${PYTHONHASHSEED-}"
```

`${TZ-}` expands to an empty value if unset without failing strict mode. `%q` emits shell-reusable escaping, making empty and special values visible. `SOURCE_DATE_EPOCH` is an integer timestamp used by supporting tools as a stable source-related time. `PYTHONHASHSEED` illustrates language runtime variance; modern Python preserves insertion order for dictionaries, but hash randomization can still affect sets and code that relies on hash iteration.

Trap: setting variables without verifying tool support. Evidence must show the generator used the intended value, not merely that a parent shell exported it.

### Decoder 6: compare exact artifacts

```bash
sha256sum artifact-a.bin artifact-b.bin
cmp -s -- artifact-a.bin artifact-b.bin
printf 'cmp_status=%s\n' "$?"
```

`sha256sum` produces human-reviewable identities. `cmp -s` performs a silent byte comparison; status 0 means equal, 1 means different, and greater values indicate an error. Capture `$?` immediately. Another command overwrites it.

Trap: using `set -e` around an expected `cmp` difference without a conditional. The shell may exit before you classify status 1. Write `if cmp -s ...; then ...; else status=$?; ...; fi` in automation.

### Decoder 7: inspect archive metadata without extraction

```bash
tar --full-time --numeric-owner -tvf artifact.tar
```

`-t` lists, `-v` adds metadata, and `-f` names the archive. `--full-time` avoids hiding subsecond/timezone clues. `--numeric-owner` avoids local username resolution differences. Compare path order, timestamps, owner/group, permissions, link targets, and size.

Trap: extracting an untrusted archive into the repository or home directory. Malicious paths and links can escape naive targets. Use a disposable isolated directory and a reviewed extraction tool when extraction is necessary.

### Decoder 8: compare Git-visible context candidates

```bash
git ls-files -co --exclude-standard -z |
  LC_ALL=C sort -z |
  tr '\0' '\n'
```

`-c` selects cached tracked paths and `-o` selects other untracked paths. `--exclude-standard` applies standard ignore rules. `-z` protects path boundaries. Sorting makes comparisons stable; `tr` converts delimiters only for display.

This is not Docker's context algorithm and does not show ignored files. Compare the actual builder's ignore rules and received-context digest. If a credential path appears, stop the transfer and rotate based on exposure, not only on whether the build later copied it.

### Decoder 9: separate JSON syntax from lock meaning

```bash
python3 -m json.tool deps.lock.json >/dev/null
printf 'json_status=%s\n' "$?"
```

The module parses JSON and returns nonzero on syntax errors. Redirecting stdout hides pretty-printed content, not stderr. A zero status says only that one parser accepted the syntax. JSON can be syntactically valid yet have a wrong schema, unknown lock version, duplicate-key ambiguity, missing integrity, or a graph inconsistent with the manifest.

Trap: allowing a normal install command to rewrite a stale lock during CI. Use the ecosystem's frozen or CI install mode so disagreement fails rather than silently resolving new versions.

### Decoder 10: bind SBOM subject to artifact

The one-line Python command in the command card calculates artifact SHA-256 and reads one CycloneDX-style subject field. Matching lines are the start of association, not the end. Validate the SBOM against the exact declared schema, reject duplicate or ambiguous components, confirm component identities and relationships, verify the generator and signature, then apply policy.

Trap: treating an SBOM as a vulnerability scan. An SBOM is inventory. Vulnerability analysis maps inventory to advisories under time-dependent databases and still needs reachability, exploitability, and remediation decisions.

### Decoder 11: bind provenance subject to artifact

The provenance command performs the same first association check against `subject[0].digest.sha256`. Production verification must additionally validate the in-toto envelope or supported format, signature, certificate or key identity, issuer, workflow identity, repository, builder, build type, parameters, materials, and policy.

Trap: validating a signature cryptographically but accepting any signer. A key can sign a perfectly valid lie. Trust means the identity is authorized for this repository, workflow, and release policy.

### Decoder 12: verify the guarded model

```bash
bash verify.sh
```

The verifier mutates only its exact current-user `/tmp` state. It runs both cases, previews setup and cleanup, refuses invalid transitions, changes its installed model to prove tamper detection, substitutes a symlink toward a canary, redirects the descriptor, creates an orphan, simulates cleanup interruption, resumes, and checks final absence.

Trap: reading `verification_passed=true` as proof of production reproducibility. It proves the encoded local behaviors only. Independent learner reasoning and real builder controls need separate review.

## Decision path

Use this decision path before promotion:

```text
1. Are source, target, instructions, and requested operation immutable?
   no  -> refuse and canonicalize intent
   yes -> continue

2. Is dependency closure exact and integrity-valid?
   no  -> refuse; preserve drift; restore or review an update
   yes -> continue

3. Is context allowlisted, secret-safe, and content-identified?
   no  -> refuse before transfer/build
   yes -> continue

4. Is builder/toolchain identity pinned and environment controlled?
   no  -> classify output as unverified
   yes -> continue

5. Is a cache candidate selected by a complete scoped key?
   no  -> do not reuse; quarantine narrowly if suspect
   yes -> validate entry, then continue

6. Do two clean builds produce equal specified artifact bytes?
   no  -> preserve and localize first variance
   yes -> continue

7. Do SBOM/provenance subjects match, and does trusted policy pass?
   no  -> refuse association or promotion
   yes -> continue

8. Can promotion atomically select one immutable digest?
   no  -> fix release-state ownership
   yes -> promote and verify consumer readback
```

Text alternative: each gate closes a different uncertainty. No later green signal repairs an earlier invalid input. A cache hit cannot repair dependency drift; a signature cannot repair a subject mismatch; a deployment health check cannot prove which artifact was built.

### Retry rules

Retry only a transient attempt, not a changed logical request. Keep the source, lock, target, builder definition, parameters, and operation ID stable. Before retrying after an ambiguous publication timeout, query the artifact repository by immutable digest or operation receipt. If the artifact already exists and passes policy, record committed. If absence is authoritative and the error is retryable, perform a bounded retry. If neither is known, retain unknown and escalate.

Do not generate a new version, cache namespace, or operation ID merely to make a failed attempt look fresh. That can produce duplicates and destroy correlation.

### Rollback rules

Rollback deploys or re-promotes a previously verified immutable artifact. It does not rebuild an old commit using today's mutable dependencies and call the result the same version. Store enough artifacts and attestations to make rollback an identity selection, not an archaeological build.

## Guided Ubuntu lab

The lab lives at `book/labs/LES-0022-reproducible-builds-dependencies`. Read its environment card before running anything.

### Phase A: prove the boundary

```bash
bash lab.sh check
LAB_DRY_RUN=1 bash lab.sh setup
bash lab.sh setup
bash lab.sh status
```

Predict the output first. `check` should report non-root, network none, and absent state. Dry-run should describe one private root and one descriptor but leave state absent. Setup creates only guarded state under `/tmp`.

### Phase B: establish the deterministic baseline

```bash
bash lab.sh run baseline
```

Copy the source, lock, dependency, context, and artifact hashes into notes. Confirm two artifact hashes match. Confirm SBOM and provenance subject digests equal the artifact digest. Explain why that still does not prove a trusted signature or a real SLSA level.

### Phase C: find volatility

```bash
bash lab.sh inject guided
bash lab.sh observe inputs
bash lab.sh observe dependencies
bash lab.sh observe context
bash lab.sh observe cache
bash lab.sh observe artifact
bash lab.sh observe supplychain
```

Write the first failed boundary. The dependency is valid. The semantic file set is equal. The naive build embeds changing clock, workspace identity, run label, and input order. Its artifact bytes differ. The normalized build removes those non-semantic fields, uses stable path/time/order, and matches.

### Phase D: recover the original operation

```bash
bash lab.sh recover
bash lab.sh verify-operation
LAB_DRY_RUN=1 bash lab.sh cleanup
bash lab.sh status
bash lab.sh cleanup
bash lab.sh check
```

Do not say "we fixed the hash." Say what changed: volatile metadata was removed or normalized, the reviewed input closure remained intact, two clean modeled builds produced the same digest, subject associations matched, no duplicate promotion occurred, consumer readback passed, and cleanup proved absence.

### Lab proof limits

The Python fixture builds canonical JSON in memory. It does not install the named parser package. It does not open a socket. It does not make Docker hermetic. It does not sign provenance. The SHA-256 values are real calculations over model bytes, while the production system is deliberately absent. Good engineering states both the proof and its boundary.

## Production transfer

### npm and JavaScript

Commit `package-lock.json` for applications. Use `npm ci` in CI when the project contract is npm: it refuses disagreement between `package.json` and the lock and performs a clean installation. Preserve the npm major version and any flags that affect tree shape. The lock contains resolved locations and integrity information, but lifecycle scripts can execute code and native modules differ by platform. Separate dependency fetch from build where possible, restrict scripts according to project needs, and verify the resulting tree and artifact.

Do not run `npm install` in a release job if it may rewrite the lock. Dependency updates are reviewed source changes with tests, SBOM delta, vulnerability and license evaluation, and rollback.

### Python and pip

Exact `==` pins improve repeatability. Hash-checking requirements bind expected distribution artifacts. Include transitive dependencies and all permitted wheels/source distributions for supported platforms. A requirements file generated from one environment can be wrong for another due to markers and platform wheels. A wheelhouse can support offline availability, but compiled wheels are platform-specific.

Record Python implementation and version, build backend, compiler, system libraries, and wheel tags. `pip freeze` describes an installed environment; it is not automatically a reviewed abstract lock for every target.

### Go

`go.mod` defines module requirements and Go/toolchain policy; `go.sum` records cryptographic hashes used to authenticate module content. Module proxy and checksum database behavior matters, especially for private modules. Vendor mode can make source available offline, but vendor content and `modules.txt` must agree with the module graph. Record `go env`, toolchain identity, target OS/architecture, CGO policy, and external C toolchain when used.

### Containers

The build context is an input interface. Make it as small as possible. Use `.dockerignore` deliberately and remember Dockerfile-specific ignore rules can apply. Pin base images by digest when release reproducibility and provenance require immutable bytes. Separate dependency manifests from application source in layers to make cache boundaries intentional.

BuildKit cache keys have instruction-specific semantics. A cached `RUN` layer does not become fresh merely because a remote package repository changed. `--no-cache` forces execution but does not guarantee pulling a new base image or selecting immutable packages. Conversely, clearing caches does not solve undeclared inputs. Use immutable dependency snapshots and complete keys.

An OCI image digest identifies a manifest or index object. Platform manifests and layer compression affect identity. State whether the release artifact is a single-platform manifest, multi-platform index, exported tar, or runtime filesystem.

### Kubernetes delivery

Build once, promote by digest, and deploy that digest. Do not rebuild per cluster. An image tag in a Deployment can move; a digest pin identifies the object. Admission policy can require verified provenance or signatures, but the cluster still needs registry access, identity, rollout, health, and rollback controls.

Record the digest admitted and the digest each node runtime pulled. A healthy Pod proves a runtime health contract, not source provenance. Keep build assurance and runtime assurance connected but separate.

### CI systems

Pin third-party actions, templates, plugins, and builder images by immutable revisions where supported. Protect release jobs from untrusted cache writers and pull-request secrets. Use isolated workspaces. Publish artifacts once with immutable version preconditions. Sign attestations from the trusted builder identity, not from a later workstation.

Test warm/cold caches, duplicate delivery, concurrent publication, timeout after upload, cache service failure, mirror failure, lock mismatch, toolchain upgrade, and rollback selection. A pipeline that works only when every dependency is healthy has no incident design.

## Reliability, security, observability, capacity, and cost

### Reliability

Define build SLIs around user-relevant outcomes:

- successful verified builds divided by valid build requests;
- reproducibility comparison success by target platform;
- time from approved revision to verified artifact;
- artifact promotion success with consumer readback;
- dependency-mirror availability and integrity-failure rate;
- cache hit ratio split by trusted namespace and validation result;
- rollback artifact availability for supported releases.

Do not optimize raw job success if jobs can emit unverified artifacts. Track failure classes: invalid request, dependency unavailable, integrity rejection, context violation, builder failure, nondeterministic mismatch, attestation failure, promotion conflict, and consumer mismatch.

### Security

Use least-privilege identities for source read, dependency read, cache read/write, artifact write, signing, and promotion. These should not all be one token. A build that can rewrite source history and release storage has excessive authority.

Keep secrets out of build arguments, environment dumps, context archives, image layers, command-line process listings, logs, SBOM properties, provenance parameters, and cache keys. Use ephemeral secret mounts or platform-supported secret channels; ensure secret contents do not persist in outputs. When secret rotation must invalidate a step, include a non-secret version identifier.

Protect against dependency confusion, typosquatting, mutable registries, compromised maintainers, malicious install hooks, cache poisoning, untrusted fork writers, mix-and-match attestations, and signing-key abuse. No single format solves all of these.

### Observability

A build operation event should include:

- stable operation and attempt IDs;
- repository and immutable source revision;
- target platform and build-definition digest;
- lock, dependency closure, context, and toolchain digests;
- bounded allowlisted parameters and environment policy version;
- cache key hash, namespace, hit/miss, entry identity, and validation decision;
- phase durations, queue delay, CPU, peak memory, disk, network bytes if permitted, and output size;
- artifact subject digests;
- SBOM/provenance generation and verification result;
- signing identity reference without secret material;
- promotion precondition, repository receipt, and consumer readback;
- stable failure class and first failed boundary.

High-cardinality values such as full artifact digests are useful for trace correlation but expensive as metric labels. Put them in logs/traces or indexed records, not unbounded metric dimensions.

### Capacity

Suppose 240 builds arrive per hour, mean execution is 12 minutes, and target utilization is at most 70 percent. Average concurrent work is:

```text
240 builds/hour * 12 minutes/build / 60 minutes/hour = 48 concurrent builds
```

At 70 percent target utilization, baseline capacity is:

```text
48 / 0.70 = 68.57, so at least 69 equivalent build slots
```

That is an average, not a safe production number. Add burst arrival distribution, platform mix, large-job isolation, retry amplification, maintenance, zone failure, and cold-cache penalties. If each cold build downloads 1.5 GiB and 30 builds start together, the dependency path may see 45 GiB before retries. A mirror or cache outage can convert a compute problem into a network and registry incident.

### Cost

Caches trade compute and latency for storage, transfer, eviction, and poisoning risk. Reproducibility testing doubles selected builds by design; use risk-based sampling only where policy permits and always retain stronger gates for releases. SBOM and provenance storage is usually small relative to artifacts but grows with component count and retention.

Optimize after correctness. A complete cache key may reduce hit rate while eliminating invalid reuse. That is a reliability improvement, not a regression. Measure useful hit rate: entries reused **and subsequently verified**, divided by eligible lookups.

## Traps and prevention

### Trap: "The lockfile makes the build reproducible"

Prevention: state what the lock contains, pin the package-manager version and flags, verify fetched artifact integrity, control install scripts and platform variants, identify the installed tree, pin the toolchain, and rebuild independently.

### Trap: "The cache hit means inputs matched"

Prevention: version and inspect the key function. Include source, lock, dependency, context, toolchain, target, and flags. Scope writers. Validate entry integrity and artifact postconditions. Treat restore-prefix matches as weaker candidates.

### Trap: "Clear all caches"

Prevention: preserve and quarantine the exact suspect entry. Broad clearing destroys evidence, increases fleet load, and can turn one incident into a dependency outage.

### Trap: "Same files means same archive"

Prevention: normalize path order, timestamps, owners, groups, modes, extended metadata, and compression settings through supported tool options. Compare raw artifact bytes, not only extracted content.

### Trap: "Same hash means today's build is healthy"

Prevention: separate candidate identity from current-operation validity. Verify input closure and operation provenance. A stale cache can return known bytes while today's dependency integrity is broken.

### Trap: "Signed means safe"

Prevention: verify the signature, resolve signer identity, authorize it for the repository/workflow, validate subject and materials, enforce policy, and test artifact behavior. Signatures preserve attribution and integrity of a statement, not truth or safety by themselves.

### Trap: "SBOM means vulnerability-free"

Prevention: validate SBOM completeness and association, then perform time-aware vulnerability and license analysis. Record scanner database and policy versions. Re-scan retained artifacts when intelligence changes without rebuilding solely to update a report.

### Trap: "A container is hermetic"

Prevention: enumerate every mount, network route, secret, base image, context file, cache, clock, device, and host interface. Containers are one isolation mechanism, not an input declaration.

### Trap: mutable labels

Prevention: resolve Git branches, package channels, base-image tags, plugins, actions, and release tags to immutable identities. Store both the human label and resolved digest so operators retain usability without losing proof.

### Trap: silent lock rewrite

Prevention: use frozen/CI install modes. Generate lock changes in a reviewed update workflow. Treat diff, dependency graph, SBOM delta, advisories, licenses, tests, and rollback as part of the change.

### Trap: rebuild for every environment

Prevention: build once under the approved builder, verify, and promote the same digest. Externalize environment configuration. If platform-specific artifacts are required, build each declared target once and join them with an immutable manifest.

### Trap: broad evidence dumps

Prevention: allowlist environment and metadata, bound stdout/stderr, redact before persistence, keep secrets out of artifact/context interfaces, and test logs with canary credentials.

## Memory card and retrieval

### The one-line model

```text
artifact = Build(source, dependency bytes, toolchain, flags, environment, context)
```

If the artifact changed, either an input changed or the transformation was nondeterministic. If the artifact did not change, origin and policy can still be wrong.

### The dependency ladder

```text
manifest -> resolver -> lock -> fetched bytes -> integrity -> installed tree -> loaded code
```

Never jump from manifest or lock directly to "the runtime used it."

### The cache sentence

> A cache hit proves that a key selected an entry; it does not prove the key was complete or the entry is correct.

### The supply-chain sentence

```text
digest = which bytes
SBOM = reported contents
provenance = reported origin/process
signature = who signed the statement bytes
policy = whether that evidence is accepted
```

### Five-minute incident card

1. Freeze promotion and automatic replay.
2. Preserve both artifacts, input identities, builder records, and cache entry.
3. State consumer impact and which digest is exposed.
4. Compare raw artifact, structure, then inputs from nearest to farthest.
5. Classify valid, invalid, rejected, or unknown; do not choose by familiarity.
6. Correct the first failed boundary.
7. Rebuild twice cleanly, verify attestations and consumer digest.
8. Promote atomically or roll back to a retained verified digest.

### Retrieval prompts

- Can I name every build-affecting input?
- Do I have bytes and integrity, or only names and versions?
- What exactly did the cache key omit?
- Which artifact boundary am I comparing?
- Does the SBOM/provenance subject match this digest?
- Who signed, and is that identity authorized?
- Did two clean independent builds match?
- Which immutable digest did consumers receive?

## Complete answers

### 1. What equality supports a reproducibility claim?

The specified artifact bytes must be bit-for-bit identical for the same defined source, build instructions, and relevant build environment. State the target platform and artifact boundary. Equal extracted files are weaker than equal archive bytes; equal container filesystems are weaker than equal OCI manifest identity. Rebuilding twice in one workspace is repeatability evidence. Independent controlled builders strengthen a reproducibility claim.

### 2. Why is a pin weaker than a pin plus integrity?

A pin says which version identity to select. Without integrity, a mutable or compromised source could serve different bytes under that identity. A checksum binds expected bytes, but its trust depends on how the checksum was authorized. Together they answer selection and byte identity; signatures and trusted mirrors add attribution and availability.

### 3. Manifest, lockfile, and installed bytes: what differs?

The manifest expresses acceptable intent. The resolver chooses a complete graph under tool and platform rules. The lock records that decision. Fetch supplies package artifacts. Integrity verifies those artifacts. Installation can unpack, select variants, and run hooks. The runtime then loads a path. Each stage can diverge, so verify at the boundary your claim needs.

### 4. Why is build context an input API?

The context defines what the builder can read through `COPY`, generators, globbing, or custom scripts. An unrelated local file can alter a wildcard, invalidate cache, leak a secret, or change output. Treat the context like an API request: define allowed fields/paths, canonicalize, hash, limit size, and reject unknown data.

### 5. Why does a cache hit prove reuse rather than correctness?

The cache service evaluated its configured key and returned an entry. If the key omitted dependency, toolchain, context, target, or flags, current inputs may not be equivalent. The entry may also come from an untrusted writer or be corrupted. Validate key completeness, namespace, writer policy, entry integrity, and final artifact independently.

### 6. How can an expected artifact hash coexist with invalid inputs?

A stale cache can return old valid bytes before current dependency or context validation would affect a fresh build. The artifact identity matches history, but the current operation did not prove those inputs produced it. Promotion must either intentionally select the previously approved immutable artifact under policy or refuse the broken build. It cannot report the current build as verified.

### 7. Why are two clean builds different from two warm reruns?

Warm reruns may reuse the same cached intermediate or final artifact and repeat a hidden error consistently. Clean builders force the declared process to reconstruct results. Stronger evidence uses separate working directories and preferably separate trusted builders while holding the declared input closure constant.

### 8. What does an SBOM describe and not prove?

An SBOM reports an inventory and relationships for a subject. It can make dependency review and vulnerability mapping possible. It does not inherently prove completeness, actual inclusion, runtime reachability, absence of vulnerabilities, license compliance, authenticity, or that the artifact was built from the listed components. Validate association, schema, generator, signature, and policy.

### 9. What does provenance claim and what must be trusted?

Provenance links an artifact subject to source/materials, parameters, builder, and execution details under a format. A verifier must validate the statement and signature, resolve signer identity, trust the issuer/root, authorize that builder and workflow for this source and build type, check subjects and materials, and enforce policy. Provenance can be authentic yet reveal a non-reproducible or insecure build; it records claims, not automatic goodness.

### 10. Why does cleanup refuse an unexpected file?

Ownership is no longer proved. The file could be learner evidence, another process's data, a link toward an external target, or tampering. Recursive deletion would convert uncertainty into data loss. Preserve the refusal, inspect identity and origin, restore the exact expected state if authorized, then let the controller remove only its allowlist.

### Incident answer: two digests for one release

Declare the release unverified and stop promotion. Preserve both objects and prevent overwrite. Record consumer exposure. Compare artifact metadata and file-level hashes, then source export, lock and dependency artifacts, builder/toolchain, context, environment, flags, and cache. Warm versus cold difference makes cache identity a leading hypothesis, not a conclusion. Correct the first variance, run two clean independent builds, validate artifact and attestation subjects, atomically bind the release to one digest, verify consumer resolution, and retain the rejected object for investigation.

### Incident answer: known hash with dependency drift

Refuse the current build and do not update the lock to unreviewed bytes. Preserve the dependency artifact, lock, mirror metadata, cache key/entry, and candidate. A known candidate hash establishes candidate identity only. Quarantine the exact cache entry, determine whether drift is malicious, mutable-source behavior, platform selection, or wrong workspace state, restore an approved object or review an intentional update, construct a complete key, rebuild twice, regenerate trusted evidence, and promote only through the normal immutable policy.

## Product-company interview

### Question 1: "What is a reproducible build, and is a container enough?"

A strong answer starts with the exact claim: same defined source, build instructions, and relevant environment allow another party to reproduce bit-identical specified artifacts. A container can pin parts of userspace and improve isolation, but it may still use a mutable base tag, current time, host kernel, architecture, network, mounted context, secrets, shared caches, nondeterministic generators, or unpinned package resolution. I would pin the builder by digest, declare and verify all inputs, normalize non-semantic variance, build twice in clean environments, compare artifact bytes, and retain provenance. I would say which dimensions remain platform-specific.

### Question 2: "Our lockfile is committed. Why did dependencies change?"

I would separate manifest, resolver, lock, fetched object, integrity, installed tree, and runtime load. Then inspect package-manager version and flags, lock format, platform markers, optional/native packages, overrides, registry or mirror object digests, checksum enforcement, install scripts, global/workspace shadowing, and loaded path. A committed lock narrows resolution; it does not prove every later boundary. The fix depends on the first divergence, not on regenerating the lock blindly.

### Question 3: "Would you disable the cache during every release?"

Not automatically. A correctly scoped, integrity-protected cache can reduce latency and dependency load. I would make its key complete and versioned, isolate untrusted writers, record entry identity, and verify output independently. For high-assurance releases, I would require clean rebuild comparison or a policy-approved reproducibility check so a final cache hit cannot be the only evidence. During an incident, I would quarantine a specific entry rather than destroy the whole cache.

### Question 4: "Two image digests differ but containers behave the same. Is that acceptable?"

First clarify the artifact boundary. OCI manifest, image config, compressed layers, uncompressed filesystem, and multi-platform index have different identities. Runtime similarity does not satisfy a byte-reproducible image claim. I would compare manifest/config JSON, layer diff IDs and compressed digests, timestamps, history, annotations, path order, permissions, and base-image identity. If policy permits semantic equivalence instead, define and test that explicitly; do not silently downgrade a byte-identity claim.

### Question 5: "How do SBOM, provenance, and signing fit together?"

The artifact digest identifies bytes. The SBOM inventories reported components for that subject. Provenance reports how and from what the subject was built. A signature authenticates statement bytes under a key. Verification resolves the signer to an authorized identity, checks subject/materials and schema, and applies policy. None alone proves the artifact is vulnerability-free or correct. I would prevent mix-and-match, store attestations alongside immutable subjects, and verify before promotion and admission.

### Question 6: "A release upload timed out. Can the job retry?"

The outcome is unknown because the repository may have committed the object before the response was lost. Reuse the same logical operation and candidate digest. Query the authoritative repository or receipt. If the exact digest/version is committed and policy-valid, record success without a duplicate upload. If authoritative absence is proved and the failure is transient, retry within an attempt and elapsed-time budget. If state is conflicting or unknown, stop. Never overwrite a version or invent a new operation to hide ambiguity.

### Question 7: "How would you roll out reproducible builds without stopping delivery?"

Start with measurement. Record source, builder, dependency, context, and artifact identities; perform non-blocking duplicate builds for representative services; classify variance; fix high-frequency sources such as timestamps, paths, and archive order. Then gate release artifacts by tier, add immutable builder/dependency inputs, generate trusted provenance and SBOMs, and gradually require verification. Preserve rollback and publish SLOs. Avoid a checkbox rollout that declares success because a tool was installed.

### Question 8: "How do you know the reproducibility system itself is trustworthy?"

Pin and review the verifier, build definition, attestation format, and policy. Separate builder, signer, and promoter identities. Protect logs and release storage. Test subject substitution, wrong signer, stale provenance, omitted material, cache poisoning, concurrent publication, and compromised runner scenarios. Use independent builders or diverse rebuilders for critical artifacts where the threat model justifies it. Monitor policy bypasses and retain evidence for external audit.

### Question 9: "What metrics would you put on a build platform dashboard?"

Verified build success, reproducibility match rate by target, queue and execution latency percentiles, cold/warm breakdown, validated cache hit ratio, integrity rejection counts, context bytes, dependency fetch fan-out, artifact size, attestation/signing latency, promotion conflicts, consumer digest mismatch, and rollback artifact availability. I would not place raw repository or digest values in metric labels; use traces/logs for correlation. Alert on user impact and invariant violations, not every cache miss.

### Question 10: "Can AI generate our lockfiles and supply-chain policy?"

AI can assist with explanations, diffs, test generation, and candidate policy, but the system must remain machine-verifiable and human-accountable. A lock update changes executable inputs; it needs resolver-generated exact data, integrity, review, tests, SBOM delta, security/license evaluation, and rollback. Policy needs explicit owners, threat model, identities, exceptions, and audited enforcement. Never accept invented package versions, URLs, hashes, schema fields, or trust roots from a model without authoritative tool output and documentation.

## Independent transfer and rubric

Use `ASM-0051` and its separate `ASM-0051-response-template.md`. Do not inspect the fixture or any guided answer while working. Capture `scenario` first and write predictions before derived views.

Your response must include:

1. an independence declaration and exact environment/safety boundary;
2. raw scenario transcript before observations;
3. an architecture diagram plus text alternative;
4. at least four competing hypotheses with disconfirming tests;
5. a chronological evidence table with proof limits;
6. a complete input-closure and dependency-integrity model;
7. cache key, namespace, writer, validation, quarantine, and retry design;
8. artifact comparison and promotion decision;
9. SBOM, provenance, signature, identity, and policy verification plan;
10. bounded recovery, clean rebuild, rollback, and original-operation verification;
11. production transfer to one real ecosystem without executing a production change;
12. final verifier and cleanup proof plus a concise incident update.

The human reviewer scores five 10-point dimensions:

| Dimension | Full-credit evidence |
|---|---|
| Independent framing and hypotheses | Raw input first, safe boundary, four plausible hypotheses, predictions, disconfirming checks, explicit unknowns |
| Build and dependency mechanisms | Accurate closure, lock/resolver/artifact distinctions, nondeterminism, context, toolchain, platform, artifact boundary |
| Cache and recovery safety | Complete versioned key, trust-domain isolation, narrow quarantine, stable operation identity, bounded retries, no blind clearing |
| Supply-chain verification | Artifact/SBOM/provenance subject binding, signature identity and policy, proof limits, immutable promotion and consumer readback |
| Production transfer and communication | Concrete ecosystem mapping, observability, capacity, security, rollout, rollback, incident timeline and prevention owners |

Forty points is not automatic mastery. The reviewer must also see no critical misconception such as promoting invalid inputs, treating cache hit as proof, updating a checksum to unreviewed bytes, equating signature with safety, or using recursive cleanup around uncertain paths.

`ASM-0049` is the answered diagnostic. `ASM-0050` is the answered production incident. Use their detailed reasoning after your own attempt, not as a script to memorize.

## References and review

Primary references used for this chapter:

1. `REF-0129`: Reproducible Builds definitions
2. `REF-0130`: SOURCE_DATE_EPOCH specification
3. `REF-0131`: npm package-lock.json
4. `REF-0132`: pip repeatable installs
5. `REF-0133`: Docker build context
6. `REF-0134`: Docker build cache invalidation
7. `REF-0135`: SLSA provenance
8. `REF-0136`: CycloneDX specification overview

Review discipline:

- Recheck versioned tool documentation before applying syntax to a newer package manager, Docker/BuildKit release, provenance specification, or SBOM schema.
- Prefer primary specifications and official tool documentation over blog shorthand.
- Test the exact builder, target, resolver, cache backend, artifact format, and verifier in scope.
- Preserve a distinction between this chapter's model facts, documented product facts, local observations, and inferences.
- Review after any major toolchain, lockfile-format, cache, attestation, signing, registry, platform, or threat-model change, and no later than the metadata review date.

The durable lesson is simple: a release is not trustworthy because a build command ended. It is trustworthy only to the degree that you can name the inputs, identify the bytes, explain the transformation, authenticate the evidence, apply policy, and prove that consumers received the intended immutable artifact.
