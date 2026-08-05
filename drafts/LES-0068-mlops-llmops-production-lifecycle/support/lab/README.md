# LES-0068 guarded offline lab

This lab teaches the order of evidence checks for one MLOps or LLMOps release. It uses a JSON fixture and Python standard-library decision model. It does **not** load a model, allocate a GPU, open a socket, contact a registry, create a Kubernetes resource or send an inference request.

## Safety boundary

- Run from Ubuntu 24.04 as a normal user.
- The scripts refuse UID 0.
- The scripts refuse common external AI credentials and `KUBECONFIG`.
- The only mutable path is `/tmp/reliability-atlas-les0068-mlops-<uid>`.
- Setup uses a private umask, a sentinel, exact ownership checks and an allowlisted inventory.
- Cleanup refuses unknown files and symlinks instead of deleting an uncertain path.

## Commands

```bash
bash lab.sh doctor
bash lab.sh setup
bash lab.sh status
bash lab.sh show baseline
bash lab.sh evaluate baseline
bash lab.sh evaluate gpu-memory-overcommitted
bash lab.sh evaluate canary-version-unlabeled
bash lab.sh cleanup
```

From an absent state, `bash verify.sh` checks all 30 decisions, rejects an unknown artifact and proves cleanup. A passing result proves only the deterministic teaching lifecycle:

```text
verify=pass cases=30 refusal=true cleanup=true
```

It cannot prove model quality, artifact reproducibility, registry integrity, serving correctness, GPU health or capacity, route fairness, canary safety, drift, cost, recovery or a user outcome. Those require representative, independently reviewed runtime evidence.
