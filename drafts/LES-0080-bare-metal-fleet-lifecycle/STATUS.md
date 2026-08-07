# LES-0080 draft status

Status: **canonical requirement and official-source lock complete; lesson scaffold, guarded lab, assessments and manuscript pending**

This quarantined directory is reserved for `LES-0080` / `V09-L05` / `PRV-005`: physical-server identity and ownership; rack, power, cooling, management, provisioning and tenant-network boundaries; BMC and Redfish control; UEFI, Secure Boot and boot order; DHCP, PXE/iPXE, ephemeral agents, image identity and first boot; inspection, RAID, firmware, burn-in and hardware health; allocation, deployment, maintenance, rebuild, retirement, media sanitization, capacity and failure domains.

The curriculum audit found that `PLAN-TRK-702` required bare metal while the canonical matrix ended at `PRV-004`. `PRV-005` now gives that scope a stable owner without changing or overloading virtualization, OpenStack, Ceph or OVS/OVN ownership.

Eighteen primary or official sources were resolved on 2026-08-07. They bind Redfish 1.23.1 and its 2025.4 data model, UEFI 2.11, current iPXE and cloud-init documentation, current OpenStack Ironic architecture and lifecycle behavior, Linux RAS/AER/hardware-monitoring semantics and NIST SP 800-88 Rev. 2 media-sanitization guidance. Ironic latest pages identify development documentation and therefore establish concepts and current contracts, not proof for a deployed release.

No lesson front matter, manuscript, diagram, command decoder, model, lab lifecycle, assessment, representative BMC, physical server, switch port, PXE transaction, ephemeral agent, disk write, firmware action, burn-in, power operation, sanitization result, production evidence, formal review, learner evidence or mastery evidence exists yet. The source lock authorizes paraphrased teaching work only.
