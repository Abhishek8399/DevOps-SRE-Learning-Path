# LES-0043 Kubernetes request-path diagnosis model

## Purpose and proof boundary

Practise locating the last healthy boundary in a Kubernetes request path before proposing a change. This is an offline deterministic model: it creates no cluster, namespace, socket, packet, DNS query, Service, NetworkPolicy, CNI or Gateway object. A pass proves only that the local scripts and seven fixture classifications behave as declared.

```text
name -> Service membership -> target port -> policy -> service data plane -> cross-node path -> Gateway attachment
```

## Prerequisites and environment

- Ubuntu 24.04, Bash and Python 3.
- A normal non-root user; do not add `sudo`.
- Run from this lab directory. No network or Docker is required.
- The UID-scoped state directory `/tmp/reliability-atlas-les0043-model-<uid>` must not already exist.

## Safety and commands

| Command | Risk | What changes |
|---|---|---|
| `bash lab.sh doctor` | `[READ-ONLY]` | Checks OS, user, commands and Python syntax |
| `bash lab.sh setup` | `[MUTATING]` | Creates one mode-0700 UID-scoped directory under `/tmp` |
| `bash lab.sh list` | `[READ-ONLY]` | Prints case names and synthetic evidence |
| `bash lab.sh diagnose CASE` | `[MUTATING]` | Records one fixture diagnosis in that directory |
| `bash lab.sh verify-cases` | `[MUTATING]` | Records and verifies all seven diagnoses |
| `bash lab.sh cleanup` | `[DESTRUCTIVE — LAB STATE ONLY]` | Removes only the validated UID-scoped model directory |
| `bash verify.sh` | `[MUTATING]` | Runs setup, cases, refusal checks and cleanup |

## Guided implementation

```bash
bash lab.sh doctor
bash lab.sh setup
bash lab.sh list
bash lab.sh diagnose dns-nxdomain
bash lab.sh diagnose service-no-endpoints
bash lab.sh verify-cases
bash lab.sh cleanup
```

Expected branch markers include `doctor=pass runtime=kubernetes-network-model-only`, `diagnosis=pass`, `verification=pass cases=7`, and `cleanup=pass state_absent=true`.

## Case decoder

| Case | Evidence to notice | Correct boundary |
|---|---|---|
| `dns-nxdomain` | queried service name returns NXDOMAIN | `dns-name` |
| `service-no-endpoints` | selector matches zero ready Pod identities | `service-membership` |
| `wrong-target-port` | targetPort resolves to 8081 while listener is 8080 | `service-port` |
| `policy-deny` | source egress denies while destination ingress allows | `network-policy-egress` |
| `vip-only-failure` | Pod IP works but ClusterIP times out | `service-dataplane` |
| `cross-node-mtu` | same-node works; large cross-node traffic times out | `cross-node-mtu` |
| `gateway-rejected` | `Accepted=False` with no matching parent | `gateway-attachment` |

Use `diagnose-as` only for a deliberate challenge. For example, `bash lab.sh diagnose-as dns-nxdomain service-dataplane` must fail. This validates an answer against fixture data; it does not observe Kubernetes.

## Validation, troubleshooting and cleanup

Run `bash verify.sh`. Success ends with `verification=pass cases=7 wrong_answer=rejected cleanup_refusal=pass state_absent=true`. The verifier adds an unexpected file and proves cleanup refuses unknown inventory before removing that exact file safely.

- `reason=root`, `reason=ubuntu`, or `reason=version`: use Ubuntu 24.04 as a normal user.
- `reason=exists`: preserve the output, then use guarded cleanup only if the state validates.
- `reason=state` or `unsafe inventory`: stop; inspect ownership and file types without bypassing the guard.
- `wrong boundary`: reread the evidence and identify the earliest broken contract.

After cleanup, `test ! -e "/tmp/reliability-atlas-les0043-model-$(id -u)"` should succeed silently.

## Challenge extension

Write the next real observation and proof limit for every case—for example, the relevant `kubectl get`, `describe`, EndpointSlice, NetworkPolicy or Gateway status check. Do not claim those commands ran. Then change the thought experiment so both Pod IP and ClusterIP fail and explain why the failure boundary must move.
