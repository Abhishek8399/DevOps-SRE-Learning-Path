# LES-0046 local model

This normal-user Ubuntu 24.04 fixture teaches release-gate classification without installing Helm, Kustomize, Kubernetes, using a network, or reading credentials.

Run `bash lab.sh doctor`, `bash lab.sh setup`, `bash lab.sh list`, and `bash verify.sh`. The verifier covers all eight cases, rejects a wrong boundary, rejects an unexpected artifact, and proves exact cleanup.

Passing this fixture is not evidence that a chart, overlay, cluster, upgrade, hook, rollback, or application is safe.
