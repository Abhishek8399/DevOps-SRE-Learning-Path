# LES-0045 Kubernetes identity, RBAC, admission and tenancy model

## Purpose and proof boundary

Practise locating a rejected or dangerous request at the authentication, authorization, credential, data, admission or tenancy gate. The model is offline and never contacts a cluster, reads a token, accesses a Secret, performs an authorization review or invokes a webhook.

```text
credential -> authentication -> authorization -> admission -> persistence/runtime -> tenant boundary
```

## Prerequisites and environment

Use Ubuntu 24.04, Bash and Python 3 as a normal user. No `kubectl`, cluster, network or credential is required. Do not paste a real token or Secret. State is limited to `/tmp/reliability-atlas-les0045-model-<uid>`.

## Command contract

| Command | Risk | Effect |
|---|---|---|
| `bash lab.sh doctor` | `[READ-ONLY]` | Checks bounded prerequisites |
| `bash lab.sh setup` | `[MUTATING]` | Creates private synthetic state |
| `bash lab.sh list` | `[READ-ONLY]` | Lists eight gates/cases |
| `bash lab.sh diagnose CASE` | `[MUTATING]` | Records a synthetic classification |
| `bash lab.sh verify-cases` | `[MUTATING]` | Exercises all cases |
| `bash lab.sh cleanup` | `[DESTRUCTIVE — LAB STATE ONLY]` | Removes the validated model directory |
| `bash verify.sh` | `[MUTATING]` | Runs full lifecycle and refusal checks |

## Guided run

```bash
bash lab.sh doctor
bash lab.sh setup
bash lab.sh list
bash lab.sh diagnose expired-token
bash lab.sh diagnose missing-binding
bash lab.sh diagnose pod-security-deny
bash lab.sh diagnose tenant-escape
bash lab.sh verify-cases
bash lab.sh cleanup
```

## Case decoder

| Case | Gate | Correct boundary |
|---|---|---|
| `expired-token` | authentication | `token-expiry-audience` |
| `missing-binding` | authorization | `rbac-missing-grant` |
| `wildcard-overgrant` | authorization | `rbac-escalation` |
| `token-automount` | credential | `unnecessary-token-exposure` |
| `secret-metadata` | data | `secret-access` |
| `pod-security-deny` | admission | `pod-security-enforce` |
| `webhook-timeout` | admission | `webhook-availability` |
| `tenant-escape` | tenancy | `cross-tenant-authorization` |

Authentication success does not imply authorization. Authorization does not imply admission. Admission success does not prove runtime isolation. Secret metadata visibility and Secret payload access are separate evidence questions.

## Validation, troubleshooting and cleanup

Run `bash verify.sh`; success reports eight cases, wrong-gate rejection, cleanup refusal and absent final state. `bash lab.sh diagnose-as expired-token rbac-missing-grant` must fail because an expired/audience-invalid token has not reached RBAC evaluation.

For root/OS errors, use the declared environment. For `exists`, do not delete the path manually; use guarded cleanup after confirming ownership. For state or inventory errors, stop and preserve evidence. Verify cleanup with `test ! -e "/tmp/reliability-atlas-les0045-model-$(id -u)"`.

## Challenge extension

Write a least-privilege evidence plan for `missing-binding`: request identity, verb, API group/resource/subresource, namespace/name, relevant bindings, and authorization-review result. Then explain how you would prove that repairing the grant does not introduce cross-tenant access. Do not use a real credential in this exercise.
