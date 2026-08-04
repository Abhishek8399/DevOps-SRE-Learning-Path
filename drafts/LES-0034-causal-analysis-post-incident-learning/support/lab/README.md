# LES-0034 bounded causal-analysis lab

This offline lab teaches evidence classification, clock reconciliation, causal-graph discipline, counterfactual testing, method selection, action quality and effectiveness verification. It models a fictional queue collapse. It does not inspect a real incident or prove professional mastery.

## Safety boundary

- Run as a normal user on Ubuntu 24.04 or WSL 2 Ubuntu 24.04.
- Requires Bash, Python 3 and common GNU userland tools.
- Uses only `/tmp/reliability-atlas-les0034-$(id -u)`.
- Opens no port, contacts no network and requires no Docker, Kubernetes, cloud or production credentials.
- Refuses root, symlink state, foreign ownership, a wrong sentinel, a wrong manifest and unexpected state entries.
- Cleanup validates the exact absolute path and UID before deletion.

Inspect before running:

```bash
pwd
sed -n '1,260p' lab.sh
sed -n '1,320p' fixtures/incident_model.py
python3 -m json.tool fixtures/scenario.json >/dev/null
```

Run:

```bash
bash lab.sh doctor
bash lab.sh setup
bash lab.sh run timeline
bash lab.sh run claims
bash lab.sh run graph
bash lab.sh run counterfactual
bash lab.sh run methods
bash lab.sh run actions
bash lab.sh run verification
bash lab.sh verify
bash lab.sh cleanup
```

Expected summary:

```text
timeline: rawOrderConflict=true uncertainEvents=1
claims: unsupported=2
graph: supportedLinks=6 unsupportedLinks=1 acyclic=true
counterfactual: testable=3 confounded=1
methods: linearCoverage=4 graphCoverage=8
actions: accepted=5 rejected=3
verification: verifiedEffective=4 ineffective=1 overdue=1
```

Interpret the counters, not just the pass:

- an ordering conflict means raw clocks cannot be treated as one clock;
- unsupported means the stated confidence lacks evidence, not that the claim is necessarily false;
- an unsupported graph edge must remain tentative;
- a confounded counterfactual changes too many conditions to isolate the claimed mechanism;
- action acceptance and action effectiveness are different decisions.

`bash lab.sh verify` exercises seven cases plus lifecycle and refusal assertions. It should finish with `state_absent=true`. On failure, preserve the first failed assertion and actual output. Cleanup only this synthetic state; real evidence follows organizational retention, legal-hold, privacy and security policy.
