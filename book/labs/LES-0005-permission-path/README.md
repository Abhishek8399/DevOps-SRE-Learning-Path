# LES-0005 Ubuntu permission-path walkthrough

This walkthrough reads one existing path as the current normal user. It creates
nothing and changes no user, group, mode, owner, ACL, capability, mount, or
security policy.

```bash
bash lab.sh check
bash lab.sh observe "$PWD/README.md"
bash lab.sh cleanup
```

Choose only a non-sensitive path that you are authorized to inspect. Record the
lexical and resolved path, caller UID/GIDs/groups, capability fields, every
component's type/owner/mode, final numeric ownership, ACL mask when available,
and exact mount options. Explain the applicable owner/group/other class and the
required operation at each component.

Do not use sudo, chmod, chown, setfacl, setcap, remount, policy-disable commands,
or a production secret/configuration path. A successful read by your shell does
not prove access by a systemd service or container with different credentials.
Cleanup is intentionally `not-required`; the verifier proves only the read-only
output contract, not authorization correctness or learner mastery.
