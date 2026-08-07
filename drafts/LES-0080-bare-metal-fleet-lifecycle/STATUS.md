# LES-0080 draft status

Status: **substantive lesson, canonical requirement, official-source lock, guarded offline lab and assessment set complete; direct schemas, declared Ubuntu lifecycle, canonical regressions, hygiene, production build, feature checkpoint and tracker packaging pass**

This quarantined directory is reserved for `LES-0080` / `V09-L05` / `PRV-005`: physical-server identity and ownership; rack, power, cooling, management, provisioning and tenant-network boundaries; BMC and Redfish control; UEFI, Secure Boot and boot order; DHCP, PXE/iPXE, ephemeral agents, image identity and first boot; inspection, RAID, firmware, burn-in and hardware health; allocation, deployment, maintenance, rebuild, retirement, media sanitization, capacity and failure domains.

The curriculum audit found that `PLAN-TRK-702` required bare metal while the canonical matrix ended at `PRV-004`. `PRV-005` now gives that scope a stable owner without changing or overloading virtualization, OpenStack, Ceph or OVS/OVN ownership.

Eighteen primary or official sources were resolved on 2026-08-07. They bind Redfish 1.23.1 and its 2025.4 data model, UEFI 2.11, current iPXE and cloud-init documentation, current OpenStack Ironic architecture and lifecycle behavior, Linux RAS/AER/hardware-monitoring semantics and NIST SP 800-88 Rev. 2 media-sanitization guidance. Ironic latest pages identify development documentation and therefore establish concepts and current contracts, not proof for a deployed release.

The guarded deterministic model defines one defensible baseline and sixty-two ordered failure boundaries across user and physical identity, ownership and change authority, BMC trust and tasks, observed and requested power, firmware and boot policy, management and provisioning networks, DHCP/PXE/iPXE, image integrity, ephemeral-agent inspection, compute/memory/storage/NIC inventory, RAID and root-device selection, allocation and scheduling, deployment and first boot, workload/user proof, hardware health, failure domains, capacity, burn-in, maintenance, upgrades, recovery, sanitization and final audit cleanup.

JSON and Python validation, Bash syntax, ShellCheck, Ubuntu 24.04 UID-1000 lifecycle, exported runtime-authority refusal, root refusal, unknown-artifact refusal and exact cleanup pass with `model=valid cases=63 gates=62` and `verify=pass cases=63 refusal=true cleanup=true hardware_runtime_calls=none`. Tool inventory uses command discovery only and invokes no discovered hardware or provisioning tool.

The 11,098-word lesson has one exact H1, all eighteen canonical H2 sections in order and 154 H3 sections. It contains six text-accessible diagrams, a seventeen-stage lifecycle path, fifteen failure zooms, an ownership and evidence model, safe local and production command decoders, a twelve-gate decision path, a complete guided lab, production transfer, reliability/security/observability/capacity/performance/cost design, sixteen traps, retrieval practice, twenty complete answers, ten senior-to-staff interview scenarios, an answer-isolated independent transfer and all eighteen annotated official sources.

Direct lesson, assessment and reference schemas report zero issues and relationships are exactly 3/18.

The assessment set contains a detailed fifty-point diagnosis, a hundred-point guided production design and a hundred-point reviewer-only independent transfer. Rubrics total 50/100/100 and the independent record has zero answer-bearing fields.

Canonical content validation reports `schemas=3/3 lessons=21 assessments=63 references=172` and the generated registry matches. The schema suite passes 38 tests with one expected Windows symlink-capability skip, all 21 reader tests pass, and lint, type checking and production build pass. Pre-tracker content counts are 262 Markdown files, 51 local links and 8,255 heading anchors. Diff hygiene, prohibited-content and reparse-point scans pass.

No production command output, representative BMC, physical server, switch port, PXE transaction, ephemeral agent, disk write, firmware action, burn-in, power operation, sanitization result, production evidence, formal review, learner evidence or mastery evidence exists. The packaged manuscript remains quarantined outside the canonical registry and website until separate review, representative-runtime, learner-transfer and publication gates pass.
