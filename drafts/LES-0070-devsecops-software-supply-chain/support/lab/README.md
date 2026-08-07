# LES-0070 local evidence-gate model

This normal-user, offline lab teaches the order of software supply-chain decisions. It does **not** download dependencies, build an image, scan code, generate an SBOM, sign an artifact, verify a real attestation, contact a registry, or call Kubernetes.

## Boundary

- Ubuntu 24.04, Bash, Python 3 standard library, no network.
- Refuses root, selected credential/endpoint variables, symlinked state, wrong ownership, a wrong sentinel, pre-existing state, and unknown artifacts.
- Writes only `/tmp/reliability-atlas-les0070-supply-chain-<uid>`.
- `cleanup` removes only the exact allowlisted files and then the exact empty directory.

## Lifecycle

```bash
bash lab.sh doctor
bash lab.sh setup
bash lab.sh status
bash lab.sh evaluate baseline
bash lab.sh evaluate sbom-for-other-digest
bash lab.sh show provenance-subject-mismatch
bash lab.sh cleanup
bash verify.sh
```

The baseline means every modeled prerequisite is true. A negative case reports the **first failed boundary**, not a risk score. That is deliberate: a high score cannot compensate for an untrusted source revision, mismatched provenance subject, unauthorized signer, or bypassed admission check.

Expected final verifier line:

```text
verify=pass cases=34 refusal=true cleanup=true
```

Passing proves only fixture validation, decision ordering, refusal behavior, exact inventory, and cleanup on the machine that ran it.
