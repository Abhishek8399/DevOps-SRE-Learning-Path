# LES-0073 local performance decision lab

This is an offline experiment-ordering model, not a benchmark, profiler, tuner or hardening tool. It creates one UID-scoped directory under `/tmp`, copies synthetic JSON, evaluates 43 deterministic cases, refuses unknown artifacts and removes only its two allowlisted files.

It does **not** inspect or alter host settings, run load, write a sysctl, change a cgroup, start a service, install a tool, record a profile, contact Docker or Kubernetes, access cloud services or prove a performance improvement.

## Safe start

Use Ubuntu 24.04 as a normal user:

```bash
bash lab.sh doctor
bash lab.sh setup
bash lab.sh status
```

Read the baseline and compare common mistakes:

```bash
bash lab.sh show baseline
bash lab.sh evaluate baseline
bash lab.sh evaluate before-and-after-load-differs
bash lab.sh evaluate host-metric-used-for-throttled-container
bash lab.sh evaluate sysctl-copied-from-blog
bash lab.sh evaluate immediate-win-no-soak
```

Interpretation:

- incomparable load invalidates a before/after claim;
- host idle capacity does not disprove cgroup throttling;
- a tunable needs exact kernel/vendor semantics and a workload hypothesis;
- an immediate improvement needs regression checks and sustained observation;
- profiling scope, symbols, overhead and sensitive-data boundaries are part of evidence quality.

Prove the complete lifecycle:

```bash
bash lab.sh cleanup
bash verify.sh
```

Expected final line:

```text
verify=pass cases=43 refusal=true cleanup=true
```

Passing proves only the local model's decision ordering and cleanup. Real performance engineering requires a representative workload, controlled baseline, repeated measurements, scoped counters/profiles, approved change, canary, rollback, security review and sustained user-impact evidence.
