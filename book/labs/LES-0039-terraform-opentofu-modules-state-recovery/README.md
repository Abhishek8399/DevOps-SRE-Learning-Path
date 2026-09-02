# LES-0039 guarded local-state lab

This lab uses only a local child module, the default local backend and the built-in `terraform_data` resource. It creates state records but no cloud or external infrastructure.

Run as a normal Ubuntu user with a separately checksum-verified CLI:

```bash
bash lab.sh doctor terraform
bash lab.sh setup terraform
bash lab.sh run init
bash lab.sh run plan-v1
bash lab.sh run apply-v1
bash lab.sh run inspect-v1
bash lab.sh run stage-v2
bash lab.sh run plan-refactor
bash lab.sh run apply-refactor
bash lab.sh run inspect-v2
bash lab.sh run backup
bash lab.sh run corrupt
bash lab.sh run prove-refusal
bash lab.sh run restore
bash lab.sh run converge
bash lab.sh cleanup
```

Use `tofu` instead of `terraform` only in a separate clean lifecycle. Never alternate products against one lab state. The wrapper binds the selected binary's path, version and SHA-256, refuses root and unexpected artifacts, and removes only the exact lesson-owned `/tmp` directory after revalidation.

`apply-v1` and `apply-refactor` are exceptional bounded exercise steps. They affect only local state for built-in logical records. No command authorizes provider credentials, a remote backend, a registry download, state push, force-unlock, destroy, or external resources.
