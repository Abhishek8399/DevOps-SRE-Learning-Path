# LES-0066 guarded offline lab

This deterministic model teaches the first unsafe boundary across task definition, baseline/data/evaluation, tokens/context/embeddings/retrieval, grounding/citations, instruction trust, tool authority, human review, version lineage, privacy and rollback.

It does **not** call an AI model, API, agent, tool, network service or external resource. It contains no prompt, completion, embedding, customer data or credential. Its output is teaching evidence only.

Supported environment: Ubuntu 24.04, normal user, Bash and Python 3 standard library, no network or credentials. State is limited to `/tmp/reliability-atlas-les0066-validated-ai-<uid>`.

```bash
bash lab.sh doctor
bash lab.sh setup
bash lab.sh status
bash lab.sh evaluate baseline
bash lab.sh evaluate population-unrepresentative
bash lab.sh evaluate prompt-injection-trusted
bash lab.sh evaluate tool-authority-excessive
bash lab.sh cleanup
bash verify.sh
```

Expected: `verify=pass cases=24 refusal=true cleanup=true`. Stop on any guard failure; never bypass ownership, sentinel, symlink, unknown-artifact, credential or external-endpoint checks.
