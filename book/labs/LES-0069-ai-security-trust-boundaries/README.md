# LES-0069 guarded offline lab

This lab teaches the order of AI-security trust-boundary checks with a JSON fixture and Python standard-library decision model. It does **not** load a model or untrusted artifact, inspect a prompt, detect an attack, open a socket, execute generated code, contact a policy service, create a Kubernetes resource, use a credential or perform a downstream action.

## Safety boundary

- Run from Ubuntu 24.04 as a normal user.
- The scripts refuse UID 0.
- The scripts refuse common external AI credentials and `KUBECONFIG`.
- The only mutable path is `/tmp/reliability-atlas-les0069-ai-security-<uid>`.
- Setup uses a private umask, sentinel, exact ownership checks and allowlisted inventory.
- Cleanup refuses unknown files and symlinks instead of deleting an uncertain path.

## Commands

```bash
bash lab.sh doctor
bash lab.sh setup
bash lab.sh status
bash lab.sh show baseline
bash lab.sh evaluate retrieved-content-authoritative
bash lab.sh evaluate tool-authorization-missing
bash lab.sh evaluate containment-path-dependent
bash lab.sh cleanup
```

From an absent state, `bash verify.sh` checks all 31 decisions, rejects an unknown artifact and proves cleanup. A passing result proves only the deterministic teaching lifecycle:

```text
verify=pass cases=31 refusal=true cleanup=true
```

It cannot prove resistance to prompt injection, poisoning, leakage, unsafe output, excessive agency, artifact compromise or novel attacks. It also cannot prove a detector, sandbox, authorization service, signature policy, audit store, kill mechanism, recovery or user outcome. Those require representative, independently reviewed runtime and downstream evidence.
