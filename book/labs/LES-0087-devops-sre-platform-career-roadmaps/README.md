# LES-0087 guarded roadmap lab

This offline Ubuntu lab demonstrates structure, arithmetic, refusal and cleanup for fictional career-roadmap data. It does not inspect or score a learner, infer a level, access a resume or employer system, call a cloud, or predict hiring.

Run as a normal user:

```bash
bash lab.sh doctor
bash lab.sh setup
bash lab.sh status
bash lab.sh roadmap
bash lab.sh roles
bash lab.sh evidence
bash lab.sh dependencies
bash lab.sh capacity
bash lab.sh milestones
bash lab.sh reviews
bash lab.sh cleanup
```

Run `bash verify.sh` from absent state for all 73 cases, six calculations, credential/authority refusal, unknown-artifact preservation and exact cleanup. If a command refuses, preserve the first error. Never bypass root, ownership, symlink, private-data, credential or production-authority guards.
