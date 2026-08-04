# LES-0041 deterministic reconciliation model

This is a Kubernetes-shaped teaching model. It is not Kubernetes, does not import Kubernetes libraries, does not use `kubectl`, and does not connect to a cluster.

## Boundary

- Ubuntu 24.04 normal user, Bash and Python 3.
- No root, network, container, socket, kubeconfig, credential or cloud.
- One exact root: `/tmp/reliability-atlas-les0041-model-$UID`.
- Deterministic desired object, event sequence, UIDs and transitions.
- Cleanup refuses symlinks, owners, paths and entries outside the exact inventory.

## Guided lifecycle

```bash
bash lab.sh doctor
bash lab.sh setup
bash lab.sh submit
bash lab.sh reconcile
bash lab.sh schedule
bash lab.sh kubelet
bash lab.sh update
bash lab.sh inject-controller-stall
bash lab.sh diagnose
bash lab.sh recover
bash lab.sh verify-state
bash lab.sh cleanup
```

Run all assertions:

```bash
bash verify.sh
```

A pass proves only the deterministic model code and run. It proves no Kubernetes API, etcd, controller, scheduler, kubelet, runtime, network, storage, security or production behavior.
