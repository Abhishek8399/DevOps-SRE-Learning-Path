# LES-0071 local security reasoning lab

This is an offline decision-order model, not a penetration-testing tool. It creates one UID-scoped directory under `/tmp`, copies synthetic JSON, evaluates 36 deterministic cases, refuses unknown artifacts and removes only its two allowlisted files.

It deliberately does **not** scan a network, test a password, create a credential, call a cloud API, alter a firewall, encrypt data, exploit software or claim that a real system is secure.

## Safe start

Use Ubuntu 24.04 as a normal user. Enter this directory and confirm that cloud, cluster and Docker context variables are unset. The guard refuses root and common external-authority variables.

```bash
bash lab.sh doctor
bash lab.sh setup
bash lab.sh status
```

Read the baseline, then compare one failed boundary:

```bash
bash lab.sh show baseline
bash lab.sh evaluate baseline
bash lab.sh show object-check-missing
bash lab.sh evaluate object-check-missing
```

The second result is `authorization` even though authentication, encryption and logging are true. That is the point: a strong control elsewhere cannot repair a missing object-level authorization decision.

Explore more branches:

```bash
bash lab.sh evaluate boundary-unmapped
bash lab.sh evaluate plaintext-hop
bash lab.sh evaluate logs-mutable-by-service
bash lab.sh evaluate containment-uses-compromised-plane
```

Prove the full lifecycle and cleanup:

```bash
bash lab.sh cleanup
bash verify.sh
```

Expected final line:

```text
verify=pass cases=36 refusal=true cleanup=true
```

## What the model teaches

The evaluator stops at the earliest missing decision boundary. This is useful for reasoning: do not debate cipher choice while ownership and data classification are unknown; do not celebrate logs when nobody can contain the incident; do not accept an exception without an owner and expiry.

Real systems are not linear and a passing model proves no production control. Use it to remember the questions, then collect evidence at every real trust boundary.
