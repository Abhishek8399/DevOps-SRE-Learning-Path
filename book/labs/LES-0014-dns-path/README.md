# LES-0014 lab: follow the DNS name, cache, authority, and transport

This is an offline reasoning lab for DNS and service discovery. It never sends
a DNS packet, edits a resolver file, flushes a cache, starts a listener, enters
a namespace, contacts Kubernetes, or changes the host network. A deterministic
Python model prints evidence that resembles production facts without pretending
to be a real resolver.

The lab teaches one habit:

> Preserve the exact name and client policy, identify the answerer and its
> state, compare authority and transport separately, then verify how the
> application used the result.

A passing verifier demonstrates that the lab lifecycle and answer-isolation
guards worked. It does not certify DNS knowledge or production readiness.

## Environment and blast-radius card

Run from Ubuntu 24.04 LTS or WSL 2 Ubuntu 24.04 as a normal user.

| Property | Contract |
|---|---|
| Required tools | Bash, Python 3.8+, and standard Ubuntu core utilities |
| Privilege | Effective UID must not be zero; root is refused |
| Network | None; no socket is opened and no packet is sent |
| Host configuration | Read-only; `/etc/resolv.conf`, NSS, routes, firewall, and sysctls are untouched |
| Persistent change | None after guarded cleanup |
| Temporary state | One UID-specific descriptor and one random private directory under `/tmp` |
| Cleanup | Exact allowlist only; no recursive deletion and no wildcard deletion |
| Kubernetes/cloud | Not required and never contacted |

Abort if any guard refuses. Do not work around a refusal with `sudo`, manual
deletion, permission changes, or a different state path. The refusal is part of
the lesson: safe production engineers preserve unknown state rather than
forcing cleanup.

## Files

```text
LES-0014-dns-path/
|-- README.md
|-- lab.sh
|-- verify.sh
`-- fixtures/
    `-- dns_model.py
```

- `lab.sh` owns setup, transitions, validation, recovery, verification, and
  cleanup.
- `dns_model.py` is copied into a private lab directory with a recorded SHA-256
  digest. It emits deterministic key-value evidence and performs no I/O except
  standard output.
- `verify.sh` runs guided and independent lifecycles and deliberately tests
  refusal paths, tampering, symlink redirection, descriptor redirection,
  orphan-state refusal, answer isolation, and cleanup.

## What the model is and is not

The model is a small incident simulator. Its numbers are fixed so every learner
can discuss the same evidence. It is useful for practicing reasoning and safe
workflow.

It is not:

- a DNS client or server;
- a packet capture;
- a benchmark;
- evidence about this computer's resolver;
- evidence about CoreDNS, Kubernetes, or a cloud provider;
- a production remediation tool.

Every model output includes or implies a virtual scope. When transferring the
reasoning, replace model facts with authorized measurements from the affected
application, namespace, resolver, authority, and transport path.

## State safety model

The controller uses this descriptor:

```text
/tmp/reliability-atlas-LES-0014-<numeric-uid>.state
```

It points to exactly one root matching:

```text
/tmp/reliability-atlas-LES-0014.<eight-alphanumeric-characters>
```

Before it trusts or removes anything, the script validates:

1. the effective user is non-root;
2. `/tmp` is a real directory, root-owned, mode `1777`, and resolves to `/tmp`;
3. the descriptor is a regular non-symlink file owned by the current UID,
   mode `0600`, with one hard link and exact four-line content;
4. the registered root matches the exact prefix, is owned by the user, is mode
   `0700`, is not a symlink, and resolves to itself;
5. the sentinel identifies LES-0014 and the current UID;
6. the manifest equals the fixture's source digest;
7. the installed model is mode `0500`, has one hard link, and its digest still
   matches;
8. every item in the directory is on an exact allowlist;
9. recorded baseline, case, recovery, and verification content matches the
   deterministic model.

Cleanup removes only validated allowlisted regular files, then the exact empty
directory, then the exact descriptor. It never uses `rm -r`, `rm -rf`, a glob,
or a computed path that failed identity checks.

## Command contract

```text
bash lab.sh check
bash lab.sh setup
bash lab.sh status
bash lab.sh run baseline
bash lab.sh inject guided|independent
bash lab.sh scenario
bash lab.sh observe operation|resolver|cache|authority|transport
bash lab.sh recover
bash lab.sh verify-operation
bash lab.sh cleanup
```

`scenario` is available only for an active independent case before recovery.
It prints raw policy and transport inputs. It deliberately refuses to print a
diagnosis, computed candidate count, computed transaction count, answer key, or
recovery.

Observations are views, not conclusions:

| View | Question |
|---|---|
| `operation` | What exact lookup and endpoint-selection operation failed? |
| `resolver` | Which candidates, types, attempts, response, and resolver scope appear? |
| `cache` | Was data reused, missed, negative, retried, or evicted? |
| `authority` | What source data, serial, answer, and size does authority expose? |
| `transport` | What happened over modeled UDP and explicit TCP, and what size boundary matters? |

## Preflight

Enter the lab directory, then run:

```bash
pwd
id
bash -n lab.sh verify.sh
python3 -c 'from pathlib import Path; compile(Path("fixtures/dns_model.py").read_text(encoding="utf-8"), "dns_model.py", "exec")'
bash lab.sh check
```

Expected important lines:

```text
privilege=normal-user
network=none
execution=deterministic_dns_model
state=absent
```

`check` creates nothing. If it finds a state descriptor or matching orphan
directory, it validates or refuses; it never guesses that the object is safe.

## Baseline

Create guarded state and capture a known-good modeled operation:

```bash
bash lab.sh setup
bash lab.sh status
bash lab.sh run baseline
```

The baseline says the client resolved and selected `10.20.4.18` successfully.
It does not predict either incident. Its purpose is to establish output shape,
known operation semantics, and a comparison point.

Before injecting, say aloud:

> The baseline is virtual evidence. It proves the model emitted a successful
> lookup and selected-address operation, not that my host DNS works.

## Guided case: valid cache overlap

Inject and gather each boundary:

```bash
bash lab.sh inject guided
bash lab.sh observe operation
bash lab.sh observe resolver
bash lab.sh observe cache
bash lab.sh observe authority
bash lab.sh observe transport
```

Do not jump from "old address" to "bad authority." Build the timeline:

```text
10:02 resolver R1 caches old address with TTL 300 s
10:03 authority publishes new address
later R1 shows old address with 180 s remaining
authority shows new address and aligned replicas
```

The cache observation proves R1 retained the old positive entry. The authority
observation proves the sampled authority serves the new data. The transport
view shows that this modeled incident does not justify EDNS, UDP, TCP, firewall,
or timeout tuning.

A strong diagnosis names a **valid cache-overlap window**, not "slow
propagation." The safe modeled recovery preserves the old endpoint and advances
to cache expiry. In production you do not advance a clock; you preserve both
endpoints, observe remaining TTL and selected-address traffic, and wait or use a
bounded refresh at the proven cache owner.

Run:

```bash
bash lab.sh recover
bash lab.sh verify-operation
bash lab.sh status
bash lab.sh cleanup
bash lab.sh check
```

Verification must show `operation_success=true` and
`verification_scope=deterministic_model_only`.

## Independent case: predict before derived evidence

Start clean:

```bash
bash lab.sh setup
bash lab.sh run baseline
bash lab.sh inject independent
bash lab.sh scenario
```

Stop before `observe`. Copy the scenario into notes outside the lab directory.
It supplies:

- an input name;
- three search suffixes;
- `ndots:5`;
- A and AAAA types;
- two attempts;
- a 1200 ms operation deadline;
- advertised, response, and modeled safe UDP sizes;
- default UDP and explicit TCP outcomes.

It does not supply the candidate list, transaction count, diagnosis, or fix.
Write these before continuing:

1. candidate names in expected order, with a warning that implementations can
   vary;
2. a transaction upper bound with units and assumptions;
3. two hypotheses and one result that would disconfirm each;
4. the first observation view you want and why;
5. changes you refuse to make without stronger evidence.

Now gather views:

```bash
bash lab.sh observe operation
bash lab.sh observe resolver
bash lab.sh observe cache
bash lab.sh observe authority
bash lab.sh observe transport
```

Do not treat the observed count as a universal resolver formula. Explain the
difference between the theoretical upper bound and the model's stopped,
cached, or retried sequence. Do not say that a 1780-byte modeled answer proves
real IP fragmentation. It supports a size-and-transport hypothesis only in the
model. Explicit TCP success is a controlled comparison; it does not locate a
real UDP drop.

Complete the ASM-0027 deliverables in your notes. Only then run:

```bash
bash lab.sh recover
bash lab.sh verify-operation
bash lab.sh cleanup
```

The recovery output is intentionally visible only after you commit to an
evidence-based diagnosis. Compare your reasoning, not merely the action text.

## Refusal drills

You should see safe failures for invalid transitions:

```bash
bash lab.sh status                 # fails before setup
bash lab.sh scenario               # fails without independent case
bash lab.sh run incident           # invalid target
bash lab.sh inject unknown         # invalid case
bash lab.sh observe unknown        # invalid view
bash lab.sh verify-operation       # fails before recovery
```

Do not manually create tampered states. `verify.sh` performs bounded tests for:

- an unexpected artifact;
- a changed installed model;
- a symlink aimed at an external file that must survive;
- a descriptor redirected to an external directory;
- an unregistered orphan candidate;
- invalid input and invalid lifecycle transitions.

Each refusal is followed by an assertion that protected state was not changed.

## Full verifier

From the lab directory as a normal user:

```bash
bash verify.sh
```

Expected final lines:

```text
verification_passed=true
cases=guided,independent
answer_isolation=raw-independent-inputs-no-derived-diagnosis-or-recovery
network_mutation=none
resolver_mutation=none
cleanup_proven=true
```

The verifier runs both cases, checks idempotent setup and cleanup, validates
content tampering refusal, and proves final absence. It should leave no
`__pycache__` directory in the repository because the model is executed as a
script and source compilation is performed without importing it.

Root refusal is a separate acceptance check because a normal-user verifier
must not grant itself privilege. In an isolated test environment, an authorized
reviewer can run `bash lab.sh check` as UID 0 and confirm it fails before setup.
Do not use `sudo` in the learning lifecycle.

## What passing proves

Passing proves only:

- the tested platform could parse the scripts and model;
- normal-user guarded setup, both deterministic cases, recovery, verification,
  and cleanup completed;
- tested invalid, tampered, redirected, and orphan states were refused;
- independent raw input did not contain the verifier's forbidden derived-answer
  fields;
- final registered lab state was absent;
- the scripts performed no modeled network or resolver mutation.

Passing does not prove:

- the learner's diagnosis is correct;
- the host resolver is healthy;
- DNS works over UDP or TCP;
- a real cache honors the example TTL;
- Kubernetes DNS is available;
- production remediation is safe;
- mastery has been achieved.

## Production transfer worksheet

Before transferring, replace every virtual field:

| Model field | Production evidence |
|---|---|
| client scope | process, pod, container, node, namespace, image version |
| input name | exact application string and absolute/relative interpretation |
| resolver policy | NSS, hosts, resolv.conf, runtime, search, ndots, attempts |
| resolver identity | server address, view, cache layer, instance, timestamp |
| cache data | hit/miss, remaining TTL, stored value, cache owner |
| authority | parent delegation, server, AA, SOA serial, exact RRset |
| transport | UDP/TCP result, TC, EDNS size, response bytes, latency |
| use | candidates, selected address, connection, TLS, application result |

Production actions such as record changes, cache flushes, resolver restart,
CoreDNS scaling, pod DNS policy changes, firewall rules, or packet capture are
outside this lab. They require authorization, a diff or plan, scoped rollout,
abort conditions, rollback, and verification of the user operation.

## Retrieval card

Use **N-C-A-T-U**:

```text
N Name      exact input, candidates, type
C Client    API, NSS, namespace, cache, deadline
A Answerer  resolver, view, cache/authority, RCODE, TTL
T Transport UDP/TCP, EDNS, TC, size, time
U Use       selected endpoint and real application result
```

If you cannot fill one line with evidence, that unknown is more valuable than
a guessed root cause.
