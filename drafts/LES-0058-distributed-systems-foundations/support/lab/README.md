# LES-0058 offline boundary model

This is a deterministic teaching model, not a consensus implementation or database emulator. It opens no socket and creates no process, cluster, credential, cloud resource, durable replica, network partition, election, lease, log, or real recovery evidence.

From Ubuntu 24.04 as a normal user:

§§§bash
bash lab.sh doctor
bash lab.sh setup
bash lab.sh evaluate baseline
bash lab.sh evaluate quorum-loss
bash verify.sh
§§§

The guarded wrapper copies one synthetic fixture into an exact UID-scoped directory under §/tmp§. It refuses root, credentials, symlinks, wrong ownership, unexpected entries, unsupported operating systems, and pre-existing state. §verify.sh§ covers every decision branch, an unexpected-artifact refusal, and exact cleanup.

For a real exercise, use a reviewer-owned disposable cluster and an approved fault harness. Never inject delay, loss, clock changes, process termination, disk faults, or membership changes into a shared or production system.
