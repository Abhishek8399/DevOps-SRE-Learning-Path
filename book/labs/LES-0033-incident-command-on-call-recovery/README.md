# LES-0033 bounded incident-command lab

This lab teaches decision and coordination boundaries for on-call triage, incident declaration, command roles, mitigation selection, recovery proof, communication, handoff, and post-incident learning. It reads one fictional checked-in scenario. It does **not** contact a page, ticket, chat, email, status page, provider, identity system, or production service.

## Environment contract

| Property | Contract |
|---|---|
| Tested design target | Ubuntu 24.04 LTS or WSL 2 Ubuntu 24.04 LTS |
| Runtime | Bash and Python 3 standard library |
| User | Normal user; `lab.sh` and `verify.sh` refuse UID 0 |
| Network | None |
| Privilege | No `sudo`, capability, daemon, container, namespace, mount, or package installation |
| CPU and memory | One short-lived Python process; under 128 MiB expected |
| Disk | One private `/tmp/reliability-atlas-les0033-<uid>` directory; under 1 MiB expected |
| Ports | None |
| Changes | Sentinel, manifest, copied fixture, and at most seven JSON result files inside the exact state directory |

The output is deterministic teaching data. It is not evidence that a real incident should be declared, that a mitigation is authorized, that users recovered, that a communication is approved, or that a learner can lead under pressure.

## Preflight

Run from this directory:

```bash
# [READ-ONLY]
id
command -v bash
command -v python3
bash lab.sh doctor
python3 fixtures/incident_model.py validate-scenario fixtures/scenario.json
```

Stop if you are root, a required command is missing, the fixture fails validation, `/tmp` is not the expected real path, or existing state is refused. Never broadly delete a refused path.

## Lifecycle

```bash
# [MUTATING / BOUNDED]
bash lab.sh setup

# [READ-ONLY]
bash lab.sh status

# [MUTATING / BOUNDED]
bash lab.sh run triage
bash lab.sh run roles
bash lab.sh run mitigation
bash lab.sh run recovery
bash lab.sh run communication
bash lab.sh run handoff
bash lab.sh run review

# [MUTATING / BOUNDED]
bash lab.sh cleanup

# [READ-ONLY]
bash lab.sh status
```

Each case overwrites only its own allowed result file after validating the full state descriptor. Interpret output as a calculation over declared fictional input, not as a production verdict.

## Full verification

```bash
# [MUTATING / BOUNDED]
bash verify.sh
```

The verifier checks syntax, scenario and state contracts, seven cases, 23 semantic assertions, unexpected-file refusal, symlink-child refusal, exact cleanup, and final state absence. Its exit status is primary evidence. The final line must contain `verification=passed`, `cases=7`, `assertions=23`, and `final_state=absent`.

## Recovery and cleanup

If a case fails, preserve the first error and run `bash lab.sh status`. If state validates, run `bash lab.sh cleanup`, then repeat doctor and setup. If state is refused, preserve the exact directory for review; the script intentionally refuses ambiguous deletion.

Cleanup validates the exact `/tmp` parent, lesson-and-UID basename, resolved path, owner, sentinel, manifest, scenario, allowed child names, file types, and child owners before removal. It then proves absence.

## Troubleshooting

| Symptom | Meaning | Safe response |
|---|---|---|
| `root-not-required` | The lab was started with UID 0. | Exit the root shell and rerun as a normal Ubuntu user. |
| `missing-tool` | Bash, Python, or a core utility is absent. | Stop. Inspect the environment; installation requires a separate reviewed action. |
| `scenario-...-invalid` | Checked-in fixture shape or relationship changed. | Preserve the first error and review the fixture/model diff. |
| `state-unexpected-child` | A file outside the allowlist exists. | Do not delete broadly. Inspect exact ownership and origin. |
| `state-child-symlink` | A child can redirect outside state. | Preserve and investigate; guarded cleanup refuses it. |
| Assertion missing in `verify.sh` | Behavior differs from the reviewed contract. | Treat the first difference as evidence; do not weaken the check to gain a pass. |

## Proof boundary

Passing proves only that the checked-in fictional fixture, deterministic model, guarded state lifecycle, assertions, refusals, and cleanup behaved as encoded on the recorded environment. It does not prove page delivery, organizational authority, safe production access, severity fitness, human communication, recovery, security or legal handling, independent leadership, delayed retention, or mastery.
