# LES-0064 guarded offline lab

This lab is a deterministic architecture-boundary model for workflow orchestration and ML-platform reliability. It teaches where to look first when run identity, data intervals, retry safety, DAG status, backfill isolation, orchestration health, experiment lineage, evaluation, promotion, serving, drift, notebooks, or privacy retention is unsafe.

It does **not** start Airflow, MLflow, Jupyter, a scheduler, metadata database, worker, model registry, inference server, notebook kernel, network listener, cloud service, training job, or external resource. Its output is teaching evidence only.

## Supported environment

- Ubuntu 24.04
- normal user; UID 0 is refused
- Bash and Python 3 standard library
- no network or credentials
- state limited to `/tmp/reliability-atlas-les0064-workflow-ml-platform-<uid>`

## Guided lifecycle

From this directory:

```bash
bash lab.sh doctor
bash lab.sh setup
bash lab.sh status
bash lab.sh show baseline
bash lab.sh evaluate trigger-rule-false-green
bash lab.sh evaluate experiment-lineage-incomplete
bash lab.sh evaluate feature-skew
bash lab.sh cleanup
```

Run the complete bounded verifier only when its UID-scoped state path is absent:

```bash
bash verify.sh
```

Expected final line:

```text
verify=pass cases=22 refusal=true cleanup=true
```

## Safety and recovery

Stop if `doctor` refuses the environment, if the state path already exists, or if any unknown artifact appears. Do not bypass guards. Preserve the first error, inspect the exact UID-scoped path, and use `bash lab.sh cleanup` only after the inventory is valid. The verifier injects one unknown file, proves operations fail closed, removes only that exact file, and proves final state absence.
