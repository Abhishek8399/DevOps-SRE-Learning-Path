# LES-0075 offline experiment-gate model

This lab teaches the order of evidence and safety decisions. It does not inject a fault. Run it only as a normal Ubuntu user with no cloud, Kubernetes or Docker authority in the shell.

```bash
bash lab.sh doctor
bash lab.sh setup
bash lab.sh status
bash lab.sh evaluate baseline
bash lab.sh evaluate selector-not-resolved
bash lab.sh evaluate rollback-ran-state-still-wrong
bash lab.sh cleanup
bash verify.sh
```

Expected verifier result:

```text
verify=pass cases=47 refusal=true cleanup=true
```

The only mutation is a UID-scoped directory beneath `/tmp` containing a sentinel and copied synthetic fixture. Cleanup removes only those two allowlisted files and refuses an unknown artifact. The model opens no port, uses no network or credential, creates no load and performs no process, service, container, Kubernetes, cloud, privilege or host action.
