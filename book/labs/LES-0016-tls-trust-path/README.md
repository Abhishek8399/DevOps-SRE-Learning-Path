# LES-0016 lab: find the TLS trust owner

This lab teaches a production habit: a TLS failure belongs to one decision on
one connection leg. Find the first failed decision before changing trust,
certificates, clocks, protocols, or applications.

```text
user operation
  -> DNS and TCP destination
  -> ClientHello, SNI, and capability offer
  -> TLS terminator and certificate selection
  -> peer-presented certificate material
  -> verifier path, name, time, purpose, and policy
  -> optional client certificate validation
  -> Finished and ALPN
  -> application authorization and correct result
```

The model contains synthetic public metadata only. It does not generate, read,
copy, compare, or delete a certificate or private key. It does not start a
listener, open a network connection, send a TLS handshake, edit a trust store,
change the clock, change crypto policy, inspect another process, access a
runtime socket, start a container, contact Kubernetes, or call a cloud API.

## Environment and blast-radius card

| Item | Contract |
|---|---|
| Tested platform | Ubuntu 24.04; WSL 2 Ubuntu 24.04 supported |
| User | Normal non-root user; UID 0 is refused before mutation |
| Time | 45-75 minutes guided; 70-100 minutes independent |
| CPU | No load generator; short foreground Bash and Python commands |
| Memory | No allocation pressure; model normally uses less than 32 MiB |
| Disk | Less than 256 KiB in one private root and one UID-scoped descriptor |
| Network and ports | None; no socket, DNS, TCP, TLS, HTTP, or external request |
| Cryptographic material | No certificate, CA, CSR, key, passphrase, or token |
| Host configuration | No trust, clock, package, crypto-policy, route, or firewall change |
| Packages | No installation; Bash, Python 3.8+, and base Ubuntu tools |
| Privilege | No sudo, capability, namespace entry, runtime socket, cluster credential, or cloud account |
| Persistent processes | None |
| Paid resources | None |
| Mutation boundary | One exact child of `/tmp` and one exact state file |

The script ignores `TMPDIR` and uses `/tmp` explicitly. Before creating state,
it requires `/tmp` to be a real root-owned sticky directory. The sticky bit
lets users create their own entries while preventing an ordinary user from
deleting entries owned by another user.

## Files

```text
LES-0016-tls-trust-path/
|-- README.md
|-- lab.sh
|-- verify.sh
`-- fixtures/
    `-- tls_trust_model.py
```

The fixture is readable source because this is an open learning repository.
Do not inspect it before submitting the independent exercise. Hiding a local
file cryptographically would be fake security. Answer isolation means normal
lab output and the verifier provide evidence but no diagnosis or solution
label, the copied model is immutable during a run, and scripts never inspect
learner notes.

## State safety model

The descriptor path is exact and scoped to the numeric user ID:

```text
/tmp/reliability-atlas-LES-0016-<numeric-uid>.state
```

It registers exactly one root matching:

```text
/tmp/reliability-atlas-LES-0016.<eight-alphanumeric-characters>
```

Before reading, writing, or deleting state, the lab validates:

- the descriptor is a single-link mode-`0600` regular file owned by the user;
- descriptor fields, values, and order are exact;
- the root is a direct child of `/tmp`, not a symbolic link, and resolves to itself;
- the root is owned by the current UID with mode `0700`;
- a lesson/version/UID sentinel is exact and mode `0400`;
- the artifact manifest is unchanged and mode `0400`;
- every direct child appears on a fixed allowlist;
- regular files have expected ownership, mode, and one hard link;
- the copied mode-`0500` model equals reviewed repository source;
- recorded output equals deterministic model output for the active case;
- lifecycle dependencies remain valid;
- derived evidence cannot be read until raw inputs have been observed.

If an unregistered directory matches the lesson pattern, the lab refuses to
guess. It never recursively removes a discovered path. Inspect its ownership
and history instead of adding `sudo` or weakening the boundary.

## Command contract

Run every command from this directory.

| Command | Mutation | Purpose |
|---|---|---|
| `bash lab.sh check` | None | Validate environment and registered state or prove absence. |
| `bash lab.sh setup` | Bounded | Create guarded private state; repeated setup is idempotent. |
| `bash lab.sh status` | None | Validate and summarize lifecycle state. |
| `bash lab.sh run baseline` | Bounded | Record immutable known-good model output once. |
| `bash lab.sh inject guided` | Bounded | Select the guided virtual incident. |
| `bash lab.sh inject independent` | Bounded | Select the answer-isolated transfer incident. |
| `bash lab.sh observe inputs` | Bounded marker | Print raw operation inputs and open the hypothesis checkpoint. |
| `bash lab.sh observe handshake` | None | Read progress, negotiated fields, alert, and application-data boundary. |
| `bash lab.sh observe certificate` | None | Read synthetic public leaf and presentation metadata. |
| `bash lab.sh observe trust` | None | Read verifier path, anchor, name, time, purpose, and policy evidence. |
| `bash lab.sh observe rotation` | None | Read presenter, trust-adoption, connection, and rollback evidence. |
| `bash lab.sh observe ownership` | None | Read control-plane and runtime ownership fields. |
| `bash lab.sh recover` | Bounded | Record the case-specific modeled configuration action. |
| `bash lab.sh verify-operation` | Bounded | Record a separate post-change operation verification. |
| `bash lab.sh cleanup` | Bounded | Delete only revalidated allowlisted state. |
| `bash verify.sh` | Bounded | Exercise both lifecycles and refusal boundaries from clean state. |

Arguments are closed allowlists. Unknown commands, shell fragments, paths,
extra arguments, unsupported cases/views, repeated baseline, second incident,
premature derived evidence, repeated recovery, and repeated verification are
refused. No command accepts an arbitrary path.

## Preflight

```bash
bash lab.sh check
```

A clean result is:

```text
lesson_id=LES-0016
environment=ready
privilege=normal-user
network=none
execution=deterministic_public_metadata_model
state=absent
next_command=bash lab.sh setup
```

If root, a dependency, `/tmp`, an orphan candidate, or registered state fails a
guard, stop. Do not install packages, use sudo, manually delete a guessed path,
or continue from partially trusted state.

## Baseline

```bash
bash lab.sh setup
bash lab.sh status
bash lab.sh run baseline
```

The baseline is fixed evidence for a known-good virtual operation. It is not
telemetry from this computer. A second baseline is refused so it cannot be
silently replaced after the incident appears.

Decode field units before comparison:

| Field pattern | Unit or meaning |
|---|---|
| `*_epoch` | Synthetic UTC seconds since Unix epoch |
| `*_seconds_remaining` | Duration in seconds under the modeled clock |
| `*_percent` | Percentage from 0 through 100 with a modeled denominator |
| `presented_certificates` | Count of peer-presented certificate objects |
| `*_present`, `*_valid`, `*_match`, `*_success` | Boolean for the named scope |
| `*_generation` | Opaque deployment or configuration generation, not a quantity |
| `path_result`, `tls_alert`, `first_error` | Categorical evidence, not a count |

Do not subtract a generation from a time or compare a percentage with a count.
Ask which population and instant each field represents.

## Guided case

Select the case and inspect only raw inputs:

```bash
bash lab.sh inject guided
bash lab.sh observe inputs
```

The input command creates a small marker so the script can enforce evidence
order. It does not score or read your hypotheses. Before proceeding, write:

```text
Exact failed operation:
Client role and cohort:
Server role and endpoint cohort:
Transport endpoint:
Reference identity:
SNI:
Client certificate required or not:
Failure phase and first error:
Verifier clock:

Mechanism 1:
Evidence that would support it:
Evidence that would disconfirm it:

Mechanism 2:
Evidence that would support it:
Evidence that would disconfirm it:

Mechanism 3:
Evidence that would support it:
Evidence that would disconfirm it:
```

Now observe one boundary at a time:

```bash
bash lab.sh observe handshake
bash lab.sh observe certificate
bash lab.sh observe trust
bash lab.sh observe rotation
bash lab.sh observe ownership
```

For every view, record:

```text
Observation and unit:
Owner and scope:
Known-good comparison:
What it proves:
What it does not prove:
Next disconfirming evidence:
```

Use the evidence to identify the last known-good and first abnormal boundary.
Do not choose the numerically largest field as the cause. A correct SAN does
not prove a path. A full endpoint rollout does not prove trust adoption. A
path error does not prove the clock is correct unless clock evidence exists.

Once the owner and smallest safe action are justified:

```bash
bash lab.sh recover
bash lab.sh verify-operation
bash lab.sh status
bash lab.sh cleanup
bash lab.sh check
```

`recover` records change execution. Only `verify-operation` checks the modeled
fresh handshake, path, identity, time, purpose, client-auth expectation, ALPN,
application correctness, and cohort coverage. This teaches a production rule:
a successful configuration API response is not a recovered service.

## Independent case

Start from clean state:

```bash
bash lab.sh setup
bash lab.sh run baseline
bash lab.sh inject independent
bash lab.sh observe inputs
```

Write hypotheses before derived views, then use the same five observation
commands. The lab prints no root-cause, diagnosis, recommended action, scoring
result, or solution key. Do not read the fixture before submitting your note.

Deliver an incident note containing:

1. the exact operation, phase, direction, endpoint, identity expectations,
   client-auth expectation, UTC clock, error, and affected cohort;
2. a diagram of every TLS, trust, termination, and authorization boundary;
3. an evidence table with units, scope, comparisons, proof limits, and next tests;
4. at least three competing mechanisms and one disconfirming test for each;
5. last known-good and first abnormal boundaries;
6. a public-metadata-only certificate, trust, and rollout inventory;
7. one owner-correct recovery with prerequisite gate, canary, blast radius,
   approval, rollback trigger, and rollback action;
8. fresh, resumed/reused, identity, authorization, cohort, and real-operation
   verification through a defined observation window;
9. prevention for issuance, delivery, reload, telemetry, clocks, rotation,
   private-key custody, capacity, cost, and ownership;
10. a five-minute explanation that states impact, evidence, uncertainty, action,
    safety, rollback, and follow-up.

Assessment `ASM-0033` contains the 30-point reviewer-only rubric and no model
answer. Verifier success cannot award mastery.

## Cleanup

Normal cleanup is:

```bash
bash lab.sh cleanup
bash lab.sh check
```

Require:

```text
cleanup_proven=true
state=absent
```

Cleanup validates state before mutation, removes only the eight allowlisted
names if present, removes the exact empty root with `rmdir`, and removes the
exact descriptor. It does not use recursive deletion or follow symbolic links.
A refusal deliberately leaves evidence untouched.

## What the verifier proves

```bash
bash verify.sh
```

From a clean normal-user state, the verifier proves in this environment that:

- the Python source compiles without creating bytecode cache;
- guided and independent lifecycle transitions produce expected record shapes;
- setup and cleanup are idempotent where documented;
- baseline, input checkpoint, recovery, and verification ordering is enforced;
- derived evidence is refused before raw inputs;
- normal evidence exposes no diagnosis or solution label;
- unknown and extra inputs are refused;
- unexpected artifacts and a modified model cause refusal;
- a symbolic-link artifact cannot modify its external target;
- an out-of-scope descriptor cannot redirect cleanup;
- an orphan candidate is not guessed or deleted;
- final state is absent;
- no network or private-key operation is part of the scripts.

The verifier does **not** prove:

- that a learner formed or explained a correct diagnosis;
- that any production endpoint, certificate, key, trust store, clock, proxy,
  container, Kubernetes cluster, load balancer, CA, or cloud is healthy;
- that an OpenSSL command is safe against an endpoint without authorization;
- that a modeled recovery is appropriate for another incident;
- that no same-UID malicious process can interfere with another same-UID process;
- mastery, interview readiness, or independent production authority.

## Root-refusal check

The repository verification run also executes this separately as UID 0:

```bash
sudo bash lab.sh check
sudo bash verify.sh
```

Both must fail before mutation with a normal-user requirement. Do not run these
with sudo merely for routine learning; they are documented so automated test
environments can prove the refusal. Verify that no LES-0016 state path was
created by the refused commands.

## Stop conditions

Stop and inspect instead of bypassing safeguards when:

- output differs from this contract;
- root is required or accidentally used;
- a dependency is absent;
- `/tmp` ownership, stickiness, or type differs;
- a state descriptor, root, owner, mode, link count, manifest, or sentinel fails;
- an unknown artifact, model mismatch, symlink, or orphan is reported;
- any command appears to contact a network or access cryptographic material;
- you cannot state what a field proves and cannot prove;
- you are tempted to inspect the independent fixture before writing evidence.

A refusal is a successful safety outcome. Resolve provenance and ownership; do
not train yourself to defeat guardrails during uncertainty.
