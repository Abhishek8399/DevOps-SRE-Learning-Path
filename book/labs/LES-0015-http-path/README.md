# LES-0015 lab: find the HTTP-path owner

This lab teaches one habit: preserve an exact user operation, then separate
HTTP semantics, proxy behavior, cache reuse, retry attempts, connection-pool
capacity, pending work, health signals, and application correctness.

```text
original client operation
  -> trusted HTTP boundary
  -> route and policy
  -> cache lookup
       | safe hit -> response
       ` miss -> upstream attempt(s)
                    -> connection pool
                    -> pending queue
                    -> origin and dependency
                    -> response
  -> client validates status, context, content, and deadline
```

No real service is started. The lab creates no socket and sends no HTTP, DNS,
container, Kubernetes, or cloud request. A small Python program prints fixed
virtual evidence. Bash exposes that evidence through an allowlisted lifecycle
and stores only guarded records inside one lesson-owned `/tmp` directory.

## Environment and blast-radius card

| Item | Contract |
|---|---|
| Tested platform | Ubuntu 24.04; WSL 2 Ubuntu 24.04 supported |
| Identity | Normal non-root user; root is refused before mutation |
| Time | 45-60 minutes guided; 60-90 minutes independent |
| CPU | No load generator; short foreground Bash and Python commands |
| Memory | No allocator pressure; normally less than 32 MiB |
| Disk | Less than 256 KiB in one exact private root plus one state descriptor |
| Network | None; no socket, bind, connect, listen, DNS, HTTP, or packet |
| Packages | No installation; Bash, Python 3.8+, and base Ubuntu tools |
| Privilege | No sudo, capability, namespace entry, runtime socket, or sysctl |
| Processes | No persistent process |
| Paid resources | None |
| Mutation | One exact child of `/tmp`, one UID-scoped state file, allowlisted records |

Stop on any refusal. Do not add `sudo`, change file permissions, edit the state
descriptor, delete a guessed directory, or weaken a guard.

## Files

```text
LES-0015-http-path/
|-- README.md
|-- lab.sh
|-- verify.sh
`-- fixtures/
    `-- http_path_model.py
```

The repository fixture is copied into the private root with mode `0500`. That
gives the owner read and execute permission without write permission. Strict
operations compare it byte-for-byte with the repository source. Reading the
fixture before submitting the independent case invalidates answer isolation;
the source remains inspectable because pretending local constants are secret
would be false security.

## State safety model

The user-specific descriptor is exactly:

```text
/tmp/reliability-atlas-LES-0015-<numeric-uid>.state
```

It records one root matching:

```text
/tmp/reliability-atlas-LES-0015.<eight-alphanumeric-characters>
```

Before reading or deleting state, the script verifies:

- `/tmp` is a real root-owned sticky directory;
- the effective user is not root;
- the descriptor is a single-link mode `0600` regular file owned by that user;
- the descriptor has exact version, lesson, UID, and root fields;
- the root is a direct child of `/tmp`, not a link, resolves to itself, is owned
  by the user, and has mode `0700`;
- the lesson/version/UID sentinel matches exactly;
- the manifest is unchanged;
- every direct child is on a closed allowlist;
- files have the expected owner, link count, and mode;
- the fixture copy equals repository source;
- recorded baseline, recovery, and verification output equals deterministic
  model output for the registered case;
- lifecycle dependencies remain valid.

An unregistered directory that matches the lesson prefix causes refusal. The
script will not guess ownership or recursively remove discovered content.

## Command contract

Run from this directory.

| Command | Mutation | Purpose |
|---|---|---|
| `bash lab.sh check` | None | Validate environment and registered state, or prove absence. |
| `bash lab.sh setup` | Bounded | Create private state; repeated valid setup is idempotent. |
| `bash lab.sh status` | None | Validate and summarize lifecycle state. |
| `bash lab.sh run baseline` | Bounded | Store immutable known-good virtual evidence once. |
| `bash lab.sh inject guided` | Bounded | Select the guided incident. |
| `bash lab.sh inject independent` | Bounded | Select the answer-isolated transfer incident. |
| `bash lab.sh scenario` | None | Show raw operation inputs without incident observations. |
| `bash lab.sh observe operation` | None | Show method, status issuer, context, correctness, and latency. |
| `bash lab.sh observe proxy` | None | Show originals, attempts, retries, deadlines, and identity source. |
| `bash lab.sh observe cache` | None | Show result, key dimensions, policy, age, validator, and auth presence. |
| `bash lab.sh observe pools` | None | Show connection, wait, queue, acquire, and reuse evidence. |
| `bash lab.sh observe health` | None | Show targets, health path, origin rate, capacity, and latency. |
| `bash lab.sh recover` | Bounded | Store the supported model recovery after diagnosis. |
| `bash lab.sh verify-operation` | Bounded | Store separate post-recovery correctness and capacity evidence. |
| `bash lab.sh cleanup` | Bounded | Delete only revalidated allowlisted exact state. |
| `bash verify.sh` | Bounded | Exercise both cases, guards, refusals, and final cleanup. |

Arguments use closed allowlists. No command accepts a path, hostname, URL,
shell fragment, arbitrary file, or configuration value.

## Preflight

```bash
bash lab.sh check
```

Clean output includes:

```text
lesson_id=LES-0015
environment=ready
privilege=normal-user
network=none
execution=deterministic_http_model
state=absent
next_command=bash lab.sh setup
```

If a dependency, identity, `/tmp`, orphan, or existing state check refuses,
stop. The lab never installs a tool or elevates privilege.

## Baseline

```bash
bash lab.sh setup
bash lab.sh status
bash lab.sh run baseline
```

Field families have different units:

| Field | Unit or meaning |
|---|---|
| `*_requests_per_second`, `*_attempts_per_second` | Rate during the model interval |
| `*_percent` | Percentage from 0 through 100 |
| `*_latency_ms`, `*_timeout_ms` | Milliseconds |
| `*_current`, `*_in_use`, `*_limit`, `*_backends` | Count at one model observation |
| `result_status` | HTTP status code emitted at the modeled boundary |
| `application_correct` | Whether the returned application contract is correct |
| `cache_key_dimensions` | Named request dimensions used by the modeled key |

Do not compare connections with requests/s. Do not call a configured limit
available capacity. Do not call HTTP 200 correct without validating context and
representation.

## Guided case

Select the case and reveal only its inputs:

```bash
bash lab.sh inject guided
bash lab.sh scenario
```

The scenario output ends with:

```text
observation_revealed=false
predict_before_observe=true
```

Before any observation, write:

```text
Exact operation and HTTP method:
Safety and idempotency contract:
Expected status, content, and deadline:
Expected cache route:
Expected attempts per original:
Possible response issuers:
Top three candidate owners:
First observation and why:
```

Then inspect one boundary at a time:

```bash
bash lab.sh observe operation
bash lab.sh observe proxy
bash lab.sh observe cache
bash lab.sh observe pools
bash lab.sh observe health
```

For every view record:

```text
Observed value and unit:
Baseline or ceiling:
Owner and scope:
What it proves:
What it cannot prove:
Candidate mechanism strengthened or weakened:
Next discriminating evidence:
```

Calculate:

```text
attempt ratio = upstream attempts per second / originals per second
extra rate = attempts per second - originals per second
estimated in-flight = attempts per second x residence seconds
```

The final formula requires an explicit service-time assumption because the
fixture gives several latency boundaries, not a universal mean. State which
boundary and time window your assumption describes.

After ranking and rejecting mechanisms:

```bash
bash lab.sh recover
bash lab.sh verify-operation
bash lab.sh status
bash lab.sh cleanup
bash lab.sh check
```

`recover` records a supported virtual change. It is deliberately separate from
`verify-operation`, which checks the modeled user result, two contexts, unsafe
cache reuse, attempt budget, pool headroom, and queue headroom. A successful
change is never itself proof of service recovery.

## Independent case

Begin only from clean state:

```bash
bash lab.sh setup
bash lab.sh run baseline
bash lab.sh inject independent
bash lab.sh scenario
```

Write predictions before observing. Then use the same five views. Normal output
does not print a root cause, diagnosis, recommended product command, or score.
The recovery action remains generic. The verifier checks output shape without
printing an answer key.

Deliver an incident note with:

1. exact operation, contexts, expected contract, and deadline;
2. HTTP and trust-boundary diagram;
3. prediction ledger created before observation;
4. evidence table with units, owner, proof, and proof limits;
5. three ranked mechanisms and two direct rejections;
6. last healthy input and first abnormal output;
7. original, miss, attempt, concurrency, pool, and queue calculations;
8. confidentiality and correctness decision;
9. bounded recovery, approval owner, abort condition, and rollback;
10. verification for both contexts and both cache population orders;
11. cleanup evidence and assistance disclosure;
12. transfer to Kubernetes, a reverse proxy, or a load balancer.

Do not read `fixtures/http_path_model.py` or the private copied model before
submitting. If you do, disclose it; finish as guided practice and repeat an
unseen transfer later.

## What the verifier proves

From clean state:

```bash
bash verify.sh
```

A passing verifier proves, for this run:

- normal-user Ubuntu-compatible lifecycle executed;
- guided and independent fixture outputs matched expected schemas;
- scenario preceded observation and carried no diagnosis label;
- invalid commands and lifecycle transitions were refused;
- a second active case was refused;
- unexpected artifacts and changed model mode were refused;
- descriptor symlink and out-of-scope redirection were refused without changing
  an external sentinel;
- an orphan lesson-shaped root blocked check, setup, and cleanup;
- cleanup was exact and final state was absent;
- no Python bytecode cache appeared in the repository;
- the model made no network mutation.

It does not prove learner reasoning, a real HTTP implementation, actual network
behavior, production capacity, Kubernetes behavior, security of a vendor
proxy, or mastery.

## Root refusal

The verifier must run as a normal user. A reviewer can separately check root
refusal in a disposable environment:

```bash
sudo -n bash lab.sh check
```

Expected result is nonzero with `run this lab from a normal non-root Ubuntu
shell`. Do not configure passwordless sudo for this test. If non-interactive
sudo is unavailable, record the test as not run rather than changing access.

## Recovery from a refusal

A refusal is not permission to clean manually. Preserve its text, inspect only
the exact descriptor and candidate with read-only commands, and ask the owner or
mentor. Never use recursive deletion, follow a symbolic link, relax mode, or
overwrite a descriptor. The verifier creates and removes only its own exact
test paths and validates an external sentinel remained unchanged.

## Reflection

1. Why can a full pool be caused by retries or slower service instead of a low limit?
2. Why does a 200 response need a context and representation correctness check?
3. Which values are rates, which are counts, and which are latency?
4. What did the scenario let you predict before evidence was exposed?
5. Which two hypotheses did you reject, and what exact observation rejected each?
6. Why does the required lab avoid a real loopback server even though one could be safe?
7. What additional evidence would be required before transferring the diagnosis to production?

The lab stays deliberately small and inspectable. Its purpose is disciplined
reasoning and safe state handling, not simulation fidelity.
