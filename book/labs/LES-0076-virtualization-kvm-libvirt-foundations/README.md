# LES-0076 offline virtualization-readiness model

This lab teaches evidence order without creating a virtual machine. Run it only as a normal Ubuntu user with no cloud, Kubernetes, Docker, or remote libvirt authority exported in the shell.

```bash
bash lab.sh doctor
bash lab.sh capability
bash lab.sh setup
bash lab.sh status
bash lab.sh evaluate baseline
bash lab.sh evaluate dev-kvm-denied
bash lab.sh evaluate qcow2-backing-file-missing
bash lab.sh evaluate running-means-ready
bash lab.sh cleanup
bash verify.sh
```

The capability command only reads architecture, virtualization environment, CPU flags, `/dev/kvm` existence/access, and local command presence. An absent KVM device or binary is valid capability evidence; this model does not install or bypass anything.

Expected verifier result:

```text
verify=pass cases=49 refusal=true cleanup=true vm_actions=none
```

The only mutation is a UID-scoped directory under `/tmp` containing a sentinel and copied synthetic fixture. Cleanup removes only those two allowlisted files and refuses an unknown artifact. The lab opens no port, uses no network or credential, creates no load, and performs no VM, image, bridge, tap, libvirt, process, package, privilege, or host action.
