# LES-0044 Kubernetes storage and recovery boundary model

## Purpose and proof boundary

Practise separating provisioning, binding, scheduling, attachment, mount, filesystem, protection and restore failures. This offline fixture performs no Kubernetes, CSI, device, mount, filesystem, snapshot or data operation.

```text
StorageClass -> PVC binding -> Pod scheduling -> attach -> mount -> application I/O -> snapshot -> restore verification
```

## Prerequisites and environment

Use Ubuntu 24.04 with Bash and Python 3 as a normal non-root user. Run from this directory with no credentials, cluster or network. The only mutable path is `/tmp/reliability-atlas-les0044-model-<uid>`.

## Command contract

| Command | Risk | Expected meaning |
|---|---|---|
| `bash lab.sh doctor` | `[READ-ONLY]` | Checks environment and prints the model-only runtime |
| `bash lab.sh setup` | `[MUTATING]` | Creates private synthetic state containing eight cases |
| `bash lab.sh list` | `[READ-ONLY]` | Lists each failure stage |
| `bash lab.sh diagnose CASE` | `[MUTATING]` | Records the fixture’s boundary |
| `bash lab.sh verify-cases` | `[MUTATING]` | Exercises all eight cases |
| `bash lab.sh cleanup` | `[DESTRUCTIVE — LAB STATE ONLY]` | Deletes only validated UID-owned fixture state |
| `bash verify.sh` | `[MUTATING]` | Runs lifecycle, wrong-answer refusal, unknown-file refusal and absence proof |

## Guided run

```bash
bash lab.sh doctor
bash lab.sh setup
bash lab.sh list
bash lab.sh diagnose delayed-binding
bash lab.sh diagnose topology-conflict
bash lab.sh diagnose filesystem-enospc
bash lab.sh verify-cases
bash lab.sh cleanup
```

## Case decoder

| Case | Stage | Boundary and reasoning |
|---|---|---|
| `class-missing` | provision | `storage-class`: no valid provisioning contract exists |
| `delayed-binding` | bind | `wait-for-consumer`: topology waits for a schedulable consumer |
| `topology-conflict` | schedule | `storage-topology`: volume and workload placement cannot intersect |
| `attach-conflict` | attach | `attachment-fencing`: ownership/attach safety blocks use |
| `mount-permission` | mount | `filesystem-identity`: attachment is not filesystem authorization |
| `filesystem-enospc` | I/O | `filesystem-capacity`: bound storage can still lack blocks or inodes |
| `snapshot-unquiesced` | protect | `application-consistency`: snapshot existence is not consistent state |
| `restore-verified` | restore | `application-restore`: restored bytes require application verification |

## Validation, troubleshooting and cleanup

Run `bash verify.sh`. The final line must include `cases=8`, `wrong_answer=rejected`, `cleanup_refusal=pass`, and `state_absent=true`. A wrong answer such as `bash lab.sh diagnose-as class-missing filesystem-capacity` must fail.

If doctor rejects root or OS version, change environment rather than bypassing it. If setup reports `exists`, use guarded cleanup only after validation. If state verification fails or an unknown entry exists, stop and inspect; never use a broad wildcard. Cleanup succeeds only when `test ! -e "/tmp/reliability-atlas-les0044-model-$(id -u)"` returns zero.

## Challenge extension

For each stage, name the Kubernetes object/status and one application-level check you would collect in a disposable cluster. Then change the scenario so a restore completes but referential integrity fails; explain why infrastructure restore completion cannot close recovery.
