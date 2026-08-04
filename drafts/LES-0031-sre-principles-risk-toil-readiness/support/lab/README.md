# LES-0031 bounded SRE operating-model exercise

This local lab teaches reliability, toil, ownership, readiness, and operating-review reasoning without impersonating a production service, company, team, ticket system, pager, SLO platform, or approval authority.

## Safety boundary

- Run as a normal Ubuntu 24.04 user. Root is refused with exit code `77`.
- The lab requires only Bash, Python 3, and standard core utilities.
- It makes no network, cloud, package-manager, Docker, Kubernetes, systemd, email, chat, ticket, notification, identity, or production call.
- Its only mutable state is `/tmp/reliability-atlas-les0031-<numeric-uid>`.
- Setup uses a private candidate directory, exact sentinel and manifest, non-symlink files, UID ownership checks, and atomic directory publication.
- Cleanup validates every child before removing the exact UID-scoped state. Unknown children and symlinks are refused.
- The verifier removes only the two exact adversarial entries it creates, then proves final absence.

## What the eight cases teach

| Case | Question answered | Important non-claim |
|---|---|---|
| `risk` | Which declared service has consumed more bad events than its objective permits? | Arithmetic does not approve an SLO or quantify business harm. |
| `toil` | Which recurring tasks match several toil properties, and how much time do they consume? | A heuristic is not a judgement about people or work value. |
| `automation` | Which candidate has the strongest declared first-quarter return? | Estimates omit adoption, failure, maintenance uncertainty, and opportunity cost. |
| `workload` | How much engineering capacity remains after toil, operations, and overhead? | A teaching threshold is not a universal staffing policy. |
| `ownership` | Which required decisions lack an assigned role? | A name does not prove authority, availability, or competence. |
| `readiness` | Which required evidence gaps make the fixture a no-go? | A checklist cannot discover every risk or grant launch approval. |
| `operating-review` | Which periods require reliability, page-load, toil, or change intervention? | Threshold triage is not causal analysis. |
| `incident` | Why is a renamed reactive operations team not automatically SRE? | The fixture cannot diagnose motives or prescribe one organization chart. |

## Commands

From this directory in Ubuntu:

```bash
bash lab.sh doctor
bash lab.sh setup
bash lab.sh status
bash lab.sh run risk
bash lab.sh run toil
bash lab.sh run automation
bash lab.sh run workload
bash lab.sh run ownership
bash lab.sh run readiness
bash lab.sh run operating-review
bash lab.sh run incident
bash lab.sh cleanup
```

Run the complete lifecycle and refusal verifier:

```bash
bash verify.sh
```

## Interpretation discipline

For every result, state:

1. the exact population, window, assumptions, and units;
2. the user or operator risk the result may support;
3. the responsible decision owner;
4. the safest next evidence or reversible action;
5. what the model cannot prove.

A passing verifier is mentor-operated project evidence only. It does not establish organizational adoption, production readiness, SLO approval, on-call qualification, return on investment, learner competence, an unseen transfer, retained skill, or mastery.
