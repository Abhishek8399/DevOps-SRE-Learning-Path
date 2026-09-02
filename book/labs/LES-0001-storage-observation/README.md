# LES-0001 storage observation

This is a read-only Ubuntu 24.04 walkthrough. It maps one authorized existing path to its filesystem, then reads independent block and inode counters and one object record. It creates, changes, deletes, mounts, fills, or scans nothing.

```bash
bash lab.sh check
bash lab.sh observe "$HOME"
bash lab.sh cleanup
```

Run as a normal user. Choose a non-sensitive path you are authorized to inspect. Stop rather than add `sudo` when access is missing.
