# Atlas local platform capstone

This project is a production-shaped teaching fixture for platform engineering. It converts one narrow developer request into Kubernetes desired state, applies cluster-wide guardrails, reconciles only committed Git content, injects bounded failures and proves cleanup. It is not a production distribution, cloud landing zone, managed-control-plane substitute or proof of learner mastery.

## Mental model

```text
developer intent              platform control plane                    workload data plane
ServiceRequest JSON
       |
       v
platformctl validate/render -> Git commit -> reconcile.py -> API server
                                                      |       |
                                                      |       +-> authentication / RBAC
                                                      |       +-> CEL + Pod Security + quota
                                                      |       +-> persistence / controllers
                                                      v
                                     Deployment -> ReplicaSet -> Pods
                                          |                       |
                                          +---- Service ----------+
                                                   |
                                            127.0.0.1:18080
```

When a request fails, ask which boundary rejected it. A malformed service request never reaches Kubernetes. RBAC answers whether an identity may ask. Admission answers whether an allowed request satisfies policy. Quota answers whether the tenant may consume the requested aggregate capacity. Scheduling answers whether a valid Pod fits. Readiness answers whether the running process should receive traffic. A successful HTTP probe is wider evidence than a Running phase, but still only one bounded observation.

## Requirements and safety boundary

- Ubuntu 24.04 under WSL, used as a normal user.
- Docker Desktop with Linux containers and enough space for one digest-pinned kind node image plus three node containers.
- `kubectl`, Python 3.12+, Git, Bash, curl and sha256sum.
- Network access is used only when the pinned kind binary or container images are absent.
- The Kubernetes API and demo NodePort bind to loopback. No cloud, production endpoint, credential or real data is used.
- The cluster name, image tag, state directory and cleanup targets are fixed and project-scoped.

The first cold run downloads substantial images. Later runs reuse the retained kind node-image cache. The verifier removes the cluster, kubeconfig, probe records and project workload image, but deliberately retains the verified kind binary and kind node image to avoid repeated downloads.

## One-command evidence

From this directory in Ubuntu:

```bash
bash verify.sh
```

The verifier refuses root and a pre-existing `atlas-platform` cluster. It validates scripts and Python, runs twelve unit tests, regenerates and compares desired state, creates the three-node cluster, applies policy, builds and loads the non-root workload, reconciles the committed manifest, checks the user route, proves three denial mechanisms, corrects replica drift, rolls back a failed image, evaluates 100 bounded probes, reconstructs a deleted namespace, and proves exact cleanup.

The final receipt must contain:

```text
verify=pass tests=12 nodes=3 policies=3 rbac=3 git_reconcile=true drift=true rollback=true probes=100 reconstruction=true ... production_actions=none
cleanup=pass cluster=absent state=absent workload_image=absent
```

A pass proves only those assertions under the recorded local versions. It does not prove CNI NetworkPolicy enforcement, high availability, production load, etcd recovery, secret management, organizational adoption or an in-place Kubernetes upgrade.

## Manual learning path

Run stages separately when you want to inspect cause and effect instead of waiting for the integrated receipt.

1. Install the exact local tool: `bash tools/install-kind.sh`. Read `toolchain.env` first. A name such as v0.31.0 is not integrity; the SHA-256 is the artifact identity.
2. Create the cluster: `bash cluster/create.sh`. Then run `bash cluster/status.sh` and map API server, scheduler, controllers, kubelets and Pods.
3. Bootstrap controls: `bash platform/bootstrap.sh`. The final three RBAC decisions should be same-tenant yes, secrets no and cross-tenant no.
4. Read `requests/payments-api.json`, change only a safe field and run `python3 platformctl.py check --request requests/payments-api.json`. Generate to a temporary path before replacing committed desired state.
5. Build the sample: `bash workload/build-load.sh`. The image is loaded into kind because `imagePullPolicy: Never` prevents an accidental registry pull.
6. Reconcile a committed source:

```bash
python3 ops/reconcile.py \
  --source drafts/LES-0089-kubernetes-platform-engineering-capstone/support/project/desired/team-a/payments-api.yaml \
  --revision HEAD
```

The reconciler resolves `HEAD` to a full commit, reads that file through Git rather than the mutable working tree, runs server-side diff, applies as the declared field manager and writes a receipt. `--force-conflicts` is intentional here: the platform owns generated fields. Never copy that flag into production without documenting field ownership and blast radius.

7. Observe rollout and the user path with the project kubeconfig:

```bash
kubectl --kubeconfig .state/kubeconfig rollout status deployment/payments-api -n team-a
curl -fsS http://127.0.0.1:18080/version
```

8. Run one failure at a time: `bash ops/verify-denials.sh`, `bash ops/verify-drift.sh`, `bash ops/verify-rollback.sh` and `bash ops/verify-reconstruction.sh`. Read each script first. Each has a fixed target and recovery path.
9. Finish with `bash cluster/cleanup.sh`. Never substitute a broad Docker prune; shared images and unrelated containers are outside this project’s authority.

## Directory map

- `cluster/` owns local cluster lifecycle and project kubeconfig.
- `platform/base/` owns namespaces, RBAC, quota, defaults and CEL admission.
- `requests/` is the small developer-facing API.
- `platformctl.py` validates that API and generates deterministic desired state plus catalog metadata.
- `desired/` is the application declaration consumed from a Git commit.
- `catalog/` holds ownership, lifecycle, runbook and SLO discovery metadata.
- `workload/` is a minimal non-root HTTP fixture, not a production web server.
- `ops/` owns reconciliation, SLO arithmetic and bounded failure evidence.
- `failures/` contains intentionally rejected requests.
- `docs/` explains decisions, runbooks, product boundaries and production gaps.

If a generated file differs from its request, fix the generator or request and review the diff. Do not hand-edit generated YAML and pretend the golden path still owns it.
