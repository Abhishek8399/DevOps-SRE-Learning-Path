# LES-0040 guarded Ansible lab

This fixture demonstrates inventory resolution, role expansion, deterministic templates, handlers, check-mode prediction, convergence, controlled drift, repair and exact cleanup on one Ubuntu localhost identity.

## Boundary

- Run as a normal user on Ubuntu 24.04.
- Install `ansible-core`, Bash and Python 3 through your approved local package process.
- No root, `sudo`, SSH, network endpoint, cloud, container or external collection is used.
- State is limited to `/tmp/reliability-atlas-les0040-controller-$UID` and `/tmp/reliability-atlas-les0040-managed-$UID`.
- The wrapper refuses unknown entries, owners, symlinks and paths.

## Fast path

```bash
bash lab.sh doctor
bash lab.sh setup
bash lab.sh inventory
bash lab.sh preflight
bash lab.sh check-initial
bash lab.sh apply-initial
bash lab.sh apply-steady
bash lab.sh inject-drift
bash lab.sh check-drift
bash lab.sh repair
bash lab.sh apply-steady
bash lab.sh cleanup
```

Run the complete assertion path:

```bash
bash verify.sh
```

Stop at the first failure and inspect its output. Do not use a broad recursive delete to bypass cleanup refusal.

## Proof boundary

A pass proves only this fixture on the reported host and Ansible version. It does not prove SSH, privilege escalation, external collections, service managers, dynamic inventory, fleet rollout, production health or learner mastery.
