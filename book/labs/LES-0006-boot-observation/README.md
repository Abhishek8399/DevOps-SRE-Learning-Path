# LES-0006 boot observation

This read-only Ubuntu 24.04 walkthrough identifies the kernel, PID 1, boot identity and elapsed uptime before interpreting boot or service evidence. When PID 1 is systemd and `systemd-analyze` is available, it also prints phase timing. It does not restart a service, reset a unit, edit boot configuration, install a package or require `sudo`.

```bash
bash lab.sh check
bash lab.sh observe
bash lab.sh cleanup
```

Run as a normal user. If PID 1 is not systemd, keep that result: it proves the observation boundary differs, not that the machine is broken. If journal or manager evidence requires additional authority, record the gap instead of changing permissions.
