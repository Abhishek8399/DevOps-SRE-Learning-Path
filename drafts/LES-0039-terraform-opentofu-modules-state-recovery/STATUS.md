# LES-0039 draft status

Status: **quarantined substantive candidate - not canonical, not accepted, not mastery evidence**

Last reviewed: 2026-08-04

## Completed in this checkpoint

- `LES-0039` / `V05-L03` / `TFM-002` contains 10,894 whitespace-delimited words, one H1, exactly 18 required H2 sections, six diagrams, twelve command contracts, two lab contracts and five incident patterns.
- `ASM-0100`, `ASM-0101` and answer-isolated `ASM-0102` have rubric totals of 50/100/100, with no criterion above ten points.
- `REF-0343` through `REF-0357` are fifteen current official Terraform or OpenTofu records with exact LES-0039 ownership.
- The provider-free fixture uses one local child module, local state and only the built-in `terraform_data` resource. It declares no external provider, registry module, remote backend, credential, provisioner, import or state-force operation.
- The guard checks exact v1/v2 address sets, create-only and move-only plan actions, unchanged object IDs, unchanged lineage, increasing serial, protected-state decoding and bounded fixture inventory.

## Runtime evidence

Previously checksum-matched standalone Terraform 1.15.8 and OpenTofu 1.12.1 Windows AMD64 binaries were used in separate clean `C:\tmp` directories. The archive signatures were not independently verified.

For each exact CLI, the disposable Windows path passed:

- format, local-backend initialization and validation with only the built-in provider;
- a saved v1 plan containing exactly two creates and zero updates/deletes;
- a bounded local-state apply of two logical `terraform_data` records;
- a v2 child-module refactor plan containing exactly two address moves and zero create/update/delete actions;
- refactor apply with both object IDs and lineage preserved and serial increased;
- protected-copy digest stability, deliberate malformed-state refusal and exact restore;
- post-restore address/ID/lineage validation and a zero-change convergence plan;
- explicit resolved-path validation, recursive removal of only the disposable validation directory and final absence.

Terraform advanced serial 2 to 3. OpenTofu advanced serial 1 to 2. Different IDs, lineages, serials and bytes across the two clean runs are expected and are not interoperability evidence. No product read or wrote the other product's state.

Direct record schemas report zero issues across one lesson, three assessments and fifteen references. Python in-memory compilation, fixture validation, ShellCheck and approved-host Git Bash syntax pass. All fifteen official source URLs opened on the review date.

## Blocked or intentionally unproved

WSL lists Ubuntu 24.04 but startup fails before `id` with host logon-right error `0x80070569`. Therefore the normal-user Bash wrapper lifecycle, root refusal, CLI mismatch refusal, unexpected-entry refusal and cleanup execution remain unproved on Ubuntu rather than inferred from Windows.

No external provider, remote backend, backend lock, force-unlock, state push, configuration-driven import, cloud object, credential, service, user journey, cross-product state migration, formal technical/security/instructional/accessibility review, learner transfer or mastery evidence exists. The draft remains outside the canonical registry and website until its promotion gates are satisfied.
