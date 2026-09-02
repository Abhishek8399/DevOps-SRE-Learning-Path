# LES-0042 deterministic workload model

This is Kubernetes-shaped concept rehearsal, not Kubernetes. It uses no `kubectl`, cluster, network, container, credential or external process.

Run as a normal Ubuntu 24.04 user:

```bash
bash lab.sh doctor
bash lab.sh setup
bash lab.sh list
bash lab.sh diagnose pending-resources
bash lab.sh verify-cases
bash lab.sh cleanup
```

`bash verify.sh` proves eight exact model cases, rejects a wrong boundary, proves cleanup refusal for an unknown entry, recovers and proves absence. It proves no scheduler, kubelet, runtime, probe, Deployment, PDB, HPA or production behavior.
