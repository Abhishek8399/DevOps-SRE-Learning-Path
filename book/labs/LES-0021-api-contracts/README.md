# LES-0021 lab: API contracts without a real network

This lab turns API vocabulary into visible state transitions without depending on a cloud account, package download, privileged port, or external service. A deterministic Python standard-library model behaves like a tiny contract boundary. The Bash controller installs one reviewed copy into a private `/tmp` directory, records exact ownership, refuses unexpected files and symlinks, and removes only the state it can prove belongs to this lesson.

The model is intentionally offline. It does **not** open a listener or send a packet. That makes repeated failure practice safe, but it also limits the claim: verifier success proves the model and lifecycle guards behaved as designed. It does not certify a production API, OpenAPI document, gateway, authentication system, queue, webhook receiver, or network.

## Environment card

| Item | Contract |
|---|---|
| Tested platform | Ubuntu 24.04 LTS; WSL 2 Ubuntu 24.04 is supported |
| Run as | A normal non-root user; UID 0 is refused with exit status 77 |
| Time | 35-55 minutes guided; 45-75 minutes independent |
| Network | None; no socket is opened and no remote name is resolved |
| Packages | Ubuntu Bash 5+, Python 3 standard library, and normal core utilities; install nothing automatically |
| CPU/RAM/disk | One short Python process at a time; under 64 MiB RAM expected; under 64 KiB guarded state |
| Ports | None |
| Host changes | One descriptor `/tmp/reliability-atlas-LES-0021-<uid>.state` and one random private directory matching `/tmp/reliability-atlas-LES-0021.XXXXXXXX` |
| Cleanup | `bash lab.sh cleanup`; it validates owner, mode, link count, canonical path, sentinel, model bytes, and exact allowlisted children before removing individual paths |

Do not use `sudo`. Do not manually delete the descriptor or random directory. A refusal is evidence that ownership proof failed; investigate it instead of bypassing it.

## Files and trust boundaries

```text
reviewed repository files (read-only during a run)
  |
  +-- fixtures/api_contract_model.py
  +-- lab.sh
  `-- verify.sh
          |
          | setup installs an exact model copy
          v
/tmp/reliability-atlas-LES-0021.<random>/   mode 0700, current UID
  |-- .sentinel                             mode 0400
  |-- .lock                                 mode 0600
  |-- api_contract_model.py                 mode 0500, byte-for-byte checked
  |-- baseline.record                       mode 0600, after baseline
  |-- case.record                           mode 0600, after injection
  |-- recovery.record                       mode 0600, after recovery
  `-- verification.record                   mode 0600, after verification

/tmp/reliability-atlas-LES-0021-<uid>.state mode 0600, exact root registration
```

A pathname is only a name. The controller therefore rejects a symlink, wrong owner, wrong mode, hard-link count other than one, unknown child, changed model, unregistered matching directory, or descriptor pointing outside the exact random-name grammar. Cleanup never uses a wildcard or recursive deletion.

## Preflight

From this lab directory:

```bash
bash lab.sh check
```

Clean output resembles:

```text
lesson=LES-0021
state=absent
network=none
```

`state=absent` proves no registered descriptor and no matching orphan directory were observed for your UID at that instant. It does not prove another user has no lab or that `/tmp` cannot change afterward.

If a required command is missing, stop. The lab never installs it for you. On stock Ubuntu 24.04 the required tools come from Bash, Python 3, coreutils, util-linux, and findutils. Installation is an administrator decision outside this exercise.

## Guided path

### 1. Create the private model boundary

```bash
bash lab.sh setup
bash lab.sh status
```

Record `lab_root`. Setup is idempotent: a repeated setup validates and reports the same registered state rather than creating another root. If an orphan is present, setup refuses because guessing which directory to own would be unsafe.

### 2. Establish a successful baseline

```bash
bash lab.sh run baseline
```

Read every field:

- `request_content_type=application/json` says how the sender labels request bytes.
- `request_accept=application/json` says which response representation the client can consume.
- `parsed_replicas_type=int` proves the decoded Python value is an integer in this modeled run. It does not prove every producer sends an integer.
- `unicode_service=café-api` makes the character/byte distinction visible.
- `utf8_byte_count` counts encoded bytes, not displayed characters.
- `canonical_sha256` is a digest of one deterministic local representation. It is not authentication and is not a universal JSON identity rule.
- `response_status=201` reports modeled resource creation.
- `consumer_readback=valid` is the declared end-to-end baseline condition.

### 3. Inject the guided type mismatch

```bash
bash lab.sh inject guided
bash lab.sh observe request
bash lab.sh observe contract
bash lab.sh observe operation
```

The payload contains `"replicas":"3"`. Those quotation marks make the JSON value a **string**. It looks numeric to a human, but it is not the JSON number `3`. A strict server rejects it with status 422 and an `application/problem+json` body. The operation view proves the modeled state owner received zero mutation attempts. Therefore correcting and submitting a reviewed new request can be safe; retrying the invalid request unchanged cannot heal it.

Now inspect three adjacent contracts:

```bash
bash lab.sh observe page
bash lab.sh observe limit
bash lab.sh observe webhook
```

The page view shows a snapshot-bound cursor with no duplicates across two pages. The limit view shows status 429, a two-second server hint, a caller attempt budget, and a fleet budget. The webhook view separates cryptographic integrity, freshness, and event-ID deduplication. None of these facts alone proves authorization or business correctness.

### 4. Recover and verify

```bash
bash lab.sh recover
bash lab.sh verify-operation
bash lab.sh status
```

For the guided case, recovery means rejecting the bad representation before mutation and demonstrating a corrected typed value. It does not silently coerce the original string. Verification checks the modeled schema, media types, pagination, rate policy, problem details, version compatibility, replay behavior, duplicate effects, and consumer readback.

### 5. Clean and prove absence

```bash
bash lab.sh cleanup
bash lab.sh check
```

Expected final evidence includes:

```text
cleanup=complete
state=absent
cleanup_proven=true
```

## Independent path

Start only after cleanup:

```bash
bash lab.sh setup
bash lab.sh run baseline
bash lab.sh inject independent
bash lab.sh scenario
```

Copy the `scenario` output into `ASM-0048-response-template.md` **before** requesting an observation. Store your filled response outside the lab-owned random directory. The raw scenario deliberately provides request inputs but no authoritative outcome, diagnosis, recovery, receipt, duplicate count, or retry decision.

Write at least three hypotheses. Examples of hypothesis shapes—not answers—are:

1. the request was rejected before mutation;
2. the operation committed but the response missed the client deadline;
3. the outcome remains unknown because neither client nor state-owner evidence is sufficient.

For each, predict what would disconfirm it. Then request only the smallest useful view:

```bash
bash lab.sh observe request
bash lab.sh observe contract
bash lab.sh observe operation
bash lab.sh observe page
bash lab.sh observe limit
bash lab.sh observe webhook
```

Do not equate a client deadline with state-owner failure. Keep `idempotency_key=deploy-417` stable. A new key would describe a new logical operation and could create a duplicate effect.

After writing a recovery card, run:

```bash
bash lab.sh recover
bash lab.sh verify-operation
bash verify.sh
```

The final verifier starts from clean state, runs both cases, tests invalid transitions, proves the raw independent scenario contains no derived answer fields, tampers with the installed model, places a symlink toward an external canary, points the descriptor out of scope, creates an orphan candidate, proves each unsafe state is refused, restores only its exact mutations, and proves final absence.

A separate reviewer can test root refusal with:

```bash
sudo -u root -- bash lab.sh check
printf 'status=%s\n' "$?"
```

That command is shown only as a review procedure where passwordless, authorized local root execution already exists. Do not install or reconfigure `sudo` for this lab. Expected status is 77. The normal verifier itself also exits 77 when launched as root.

## Evidence questions

Answer these while the evidence is fresh:

1. Why is `"replicas":"3"` not interchangeable with `"replicas":3`?
2. Why does a valid JSON document still need schema validation?
3. What does `Content-Type` describe, and what does `Accept` describe?
4. Why is a timeout after a POST an unknown outcome rather than proof of failure?
5. Why must retry reuse the same logical idempotency key?
6. How does a snapshot cursor prevent page drift that an offset alone cannot prevent?
7. Why should 429 handling obey both a per-request deadline and a fleet retry budget?
8. Why are webhook signature verification, freshness checking, and event deduplication three separate controls?
9. What does the verifier prove, and what real systems does it not exercise?
10. Why does cleanup refuse an unexpected file even though that makes cleanup less convenient?

Complete model answers are in LES-0021. ASM-0048 remains answer-isolated and requires reviewer judgment.

## Troubleshooting refusals

| Refusal | Meaning | Safe next step |
|---|---|---|
| `root-is-refused-run-as-a-normal-user` | The effective UID is zero | Return to the intended normal-user Ubuntu shell |
| `unregistered-lesson-root-found-refusing-to-guess` | A matching directory exists without a valid descriptor | Preserve the path and inspect owner, mode, name, and contents; do not delete by pattern |
| `unexpected-child-*` | The guarded root contains an unrecognized entry | Preserve it and determine who created it; cleanup correctly refuses |
| `installed-model-differs-from-reviewed-source` | Executed model bytes no longer match the repository fixture | Stop, preserve hashes and metadata, and restore only through a reviewed exact reinstall |
| `expected-regular-file-*` | An expected path is missing, a directory, or a symlink | Stop; inspect pathname and object identity without following an untrusted link |
| `state-lock-contended` | Another invocation owns the local workflow lock | Wait for or identify that invocation; do not remove the lock file |
| `observation-unavailable-after-recovery` | The evidence phase is closed | Use the stored recovery and verification records, or clean and begin a new attempt |

## Safety and scope statement

This is a teaching model, not a security boundary against a malicious process running as the same UID. The current user can alter their own `/tmp` state and repository. The guards prevent common accidents and make ownership assumptions explicit. Real hostile-multi-tenant isolation needs operating-system identities, mandatory access controls, hardened runtime boundaries, protected artifact supply chains, and separate security review.
