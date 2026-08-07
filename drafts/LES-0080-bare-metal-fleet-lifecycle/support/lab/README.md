# LES-0080 guarded bare-metal lifecycle evidence model

This lab teaches evidence order without discovering, querying or changing a physical server, BMC, Redfish endpoint, IPMI device, firmware, boot order, DHCP/PXE service, provisioning network, switch port, disk, RAID set, operating-system image, power state or sanitization target.

Run it as a normal Ubuntu 24.04 user from this directory:

```bash
bash lab.sh doctor
bash lab.sh inventory-tools
bash lab.sh setup
bash lab.sh status
bash lab.sh evaluate bmc-certificate-or-trust-invalid
bash lab.sh evaluate architecture-or-bootfile-mismatch
bash lab.sh evaluate image-digest-or-signature-invalid
bash lab.sh evaluate desired-and-current-raid-diverged
bash lab.sh evaluate uncorrected-or-fatal-hardware-error
bash lab.sh evaluate sanitization-verification-or-validation-failed
bash verify.sh
```

The verifier covers one passing synthetic baseline and one isolated failure for each of 62 ordered gates. It proves exported credential or runtime-authority refusal, unknown-artifact refusal and exact UID-scoped cleanup. Tool inventory uses `command -v` only; no discovered hardware or provisioning tool is invoked.

The guard refuses root, known BMC/Redfish/IPMI/Ironic/MAAS/PXE/cloud/cluster/container/hypervisor authority variables and local IPMI control devices. Do not bypass it. Do not point this directory at a BMC, controller, provisioning network, real disk, switch, cloud, cluster or production system.

A representative exercise belongs only in a reviewer-owned disposable physical lab or a faithful isolated emulator with explicit ownership, credentials that cannot reach production, bounded power and load controls, stop conditions, rollback or rebuild authority, and independently verified cleanup.
