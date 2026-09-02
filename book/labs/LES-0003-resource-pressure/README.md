# LES-0003 Ubuntu observation walkthrough

This is a short, read-only Ubuntu walkthrough. It does not create CPU load,
allocate memory, change swap, edit cgroups, install packages, use sudo, or touch
the network. Its purpose is to make real command output readable before a
learner handles production pressure.

## Run

From this directory on Ubuntu, as a normal user:

```bash
bash lab.sh check
bash lab.sh observe
bash lab.sh cleanup
```

`observe` takes three one-second `vmstat` interval samples. Read it alongside
the lesson's command decoder. The values are observations of this machine and
this time window; a quiet result is valid and must not be presented as an
incident.

## What to record

Write down the CPU count, three load averages, the `r`, `b`, `si`, `so`, `us`,
`sy`, `id`, `wa`, and `st` branches, `MemAvailable`, swap used versus swap
activity, all available PSI `some`/`full` values, and the largest visible RSS
processes. For every observation, state what it proves and what it cannot prove.

## Safety and cleanup

- Supported target: Ubuntu, normal non-root user.
- Read-only inputs: `/proc`, procps commands, identity, and kernel version.
- No files or processes are created, so cleanup reports `not-required`.
- Do not add `stress`, `stress-ng`, fork bombs, swap changes, cgroup limits, or
  production commands to this walkthrough.
- `bash verify.sh` verifies the supported output contract; it does not prove
  resource pressure, application health, production behavior, or mastery.
