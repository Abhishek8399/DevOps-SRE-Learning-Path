# Lesson and Ubuntu Lab Standard

Every public lesson must be safe enough to follow, deep enough to revisit, and structured enough for another human or AI to maintain.

## Required lesson metadata

- Stable lesson ID, domain, level, and estimated time.
- Prerequisite lesson IDs.
- Tested Ubuntu and tool versions.
- Target-role mappings.
- Last-reviewed date and known limitations.
- Learning objective and production relevance.

## Required teaching sections

1. What the reader sees and where their mind should go first.
2. Term-first glossary with an everyday meaning, precise technical meaning, and on-call relevance for every prerequisite concept.
3. Big-picture architecture diagram.
4. Request, state, or connectivity path.
5. Failure zoom.
6. Internals and state ownership.
7. Evidence table: command, risk class, expected branches, proves, and does not prove.
8. Field-by-field command decoder with realistic output, units, first-row or sampling behavior, interpretation combinations, traps, and safest next evidence.
9. Decision path rather than a command dump.
10. Ubuntu-first guided lab.
11. Container, Kubernetes, cloud, or private-cloud transfer where relevant.
12. Security, reliability, observability, capacity, and cost consequences.
13. Common traps and prevention.
14. Memory card and optional retrieval questions.
15. Complete model answers that grow from a direct answer to first-year foundations and then a senior production answer.
16. Product-company interview scenario with a model answer, weak-answer analysis, evidence, and answered follow-ups.
17. Separate independent transfer exercise and scoring rubric.
18. Primary references and review schedule.

## Self-contained explanation contract

A learner must not need a search engine to decode a lesson. Before publication:

- define a term before relying on it in an explanation;
- expand an acronym on first use and explain what boundary or mechanism it names;
- state the exact question before presenting a command;
- provide realistic sample output and explain every displayed heading, field, unit, symbol, and important flag;
- distinguish a point-in-time value, interval rate, lifetime average, cumulative counter, percentage, capacity, and limit;
- explain the first row or warm-up behavior of sampling tools such as `vmstat`;
- interpret fields in combinations and connect each hypothesis to the next confirming evidence;
- state what the command cannot prove and which namespace, identity, mount, cgroup, host, or endpoint produced the evidence;
- answer every published checkpoint and interview question in the same artifact;
- include the common weak answer and explain why it can cause a wrong production decision.

Depth follows this chain instead of repeating a definition:

```text
plain-language picture -> precise mechanism -> visible evidence -> interpretation -> safe decision -> production transfer
```

## Environment card

Every lab states:

- tested Ubuntu version and whether WSL is supported;
- expected time;
- required privilege and network access;
- CPU, RAM, disk, and port requirements;
- packages and exact commands required;
- files, directories, processes, sockets, mounts, containers, or namespaces changed;
- scope, abort conditions, recovery, and cleanup proof.

## Dependency workflow

Never install before checking.

```bash
# [READ-ONLY]
command -v ps
command -v vmstat
command -v ss
```

Map missing commands to Ubuntu packages. Installation remains a separate, explicit action:

```bash
# [MUTATING / NETWORKED / REQUIRES SUDO]
sudo apt-get update
sudo apt-get install --no-install-recommends <reviewed-packages>
```

Common mappings:

| Commands | Ubuntu package |
|---|---|
| `ps`, `vmstat`, `free`, `uptime` | `procps` |
| `ip`, `ss` | `iproute2` |
| `getent` | `libc-bin` |
| `findmnt`, `namei` | `util-linux` |
| `getfacl` | `acl` |
| `curl` | `curl` |
| `openssl` | `openssl` |
| `python3` | `python3` |

## Lab sequence

```text
preflight
  -> optional reviewed install
  -> baseline
  -> prediction
  -> controlled experiment
  -> observation
  -> recovery
  -> verify the real operation
  -> cleanup
  -> prove cleanup
```

## Isolation choice

| Mechanism | Default environment |
|---|---|
| Host observation | Plain Ubuntu, read-only |
| Bounded user-space file or process change | Plain Ubuntu, non-root temporary resources |
| Inode/resource exhaustion, mounts, namespaces, cgroups | Hardened Docker lab |
| systemd, kernel, module, LVM, or firewall mutation | Disposable VM |
| Kubernetes reconciliation, controllers, Services, policy, RBAC, volumes | Local Kubernetes cluster |

## Executable lab contract

Substantial mutating labs use:

```text
labs/<lesson-id>/
|-- README.md
|-- lab.sh       # check | setup | status | cleanup | reset
|-- verify.sh
`-- fixtures/
```

Shell requirements:

- `set -Eeuo pipefail` and `umask 077`.
- No `eval`, implicit download, automatic package install, or automatic `sudo`.
- Refuse root for host-mutation labs unless root is the mechanism being taught.
- Use a lesson-specific `mktemp -d` prefix.
- Record exact state and a sentinel owned by the current UID.
- Before recursive cleanup, validate real path, expected parent, basename prefix, owner, and sentinel.
- Validate a process identity before signaling a recorded PID.
- Check ports before binding and prove the response belongs to the lab.
- Cleanup proves process, socket, and path absence.

Guided labs and mastery labs are separate. The guided lesson may reveal every step; the mastery challenge must require independent transfer.
