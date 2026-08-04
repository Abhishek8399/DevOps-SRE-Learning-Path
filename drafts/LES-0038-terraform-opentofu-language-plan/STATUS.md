# LES-0038 draft status

Status: **quarantined substantive candidate - not canonical, not accepted, not mastery evidence**

Last reviewed: 2026-08-04

## Completed in this checkpoint

- LES-0038 / V05-L02 / TFM-001 metadata and 7,240-word body pass direct lesson validation with one H1 and the exact 18 required H2 sections.
- Six diagrams, twelve command contracts, two lab contracts and five incident patterns cover HCL types, expressions, instance identity, graphs, known/unknown values, validation, tests, plans and Terraform/OpenTofu boundaries.
- ASM-0097, ASM-0098 and answer-isolated ASM-0099 pass direct assessment validation at 50/100/100 rubric totals.
- Nine new official records REF-0334 through REF-0342 pass direct reference validation; the lesson reuses six reviewed LES-0037 identities REF-0319, REF-0320, REF-0324, REF-0325, REF-0327 and REF-0330, whose LES-0038 backlinks remain a promotion-time requirement.
- Provider-free fixtures use only the built-in `terraform_data` resource and contain typed variables, validation, locals, collection transforms, stable `for_each` keys, implicit edges, plan-known tests, valid inputs and invalid inputs.

## Runtime evidence

Standalone Terraform 1.15.8 windows_amd64 and OpenTofu 1.12.1 windows_amd64 archives were downloaded to a versioned `C:\tmp` tool cache. Each archive SHA-256 matched its filename entry in the separately downloaded official checksum manifest. Signatures were not independently verified.

In separate disposable Windows directories, both CLIs passed:

- `fmt -check -diff`;
- `init -backend=false -input=false`, reporting only the built-in provider;
- `validate`;
- two plan-only native tests;
- saved plan with `valid.tfvars` and exactly three creates, zero changes and zero destroys;
- JSON plan decoding and DOT graph generation;
- expected nonzero invalid-input plan with both variable-validation messages.

Neither directory contained `.terraform.lock.hcl` or `terraform.tfstate`; `.terraform` was empty. Terraform produced a 2,760-byte opaque plan, 5,669-byte JSON view and 1,630-byte DOT graph. OpenTofu produced 2,764, 5,911 and 1,667 bytes respectively. Byte differences are not semantic incompatibility evidence. The disposable validation tree was checked for allowed children, removed, and proved absent. The tool cache remains outside the repository for continued validation.

The first Terraform test attempt failed because assertions flowed through computed resource outputs that were unknown during planning. The tests were correctly changed to assert plan-known variables, locals and instance keys. No apply was used to bypass the knowledge boundary.

The completed `lab.sh`, `verify.sh` and `guard.py` design binds CLI path/name/version/SHA-256, refuses root and external-provider/apply test declarations, restricts state to one exact UID path, validates allowed entries and ownership, permits only plan-phase cases, validates exact plan addresses/actions, rejects unexpected entries, and revalidates before bounded recursive cleanup.

Static and partial runtime checks pass:

- Python fixture validation and in-memory compilation;
- ShellCheck at warning severity for both shell scripts;
- approved-host Git Bash syntax for both scripts;
- direct schemas and exact cross-draft relationships for LES-0037/LES-0038, six assessments and 24 unique reference records;
- fresh Terraform and OpenTofu plans both pass the new guard's exact three-address/create contract, followed by validated disposal and absence.
- canonical content/registry validation, all 38 runnable schema tests, all 21 reader tests, lint, explicit typecheck, production build and patch-whitespace checks pass while published counts remain unchanged at 21 lessons, 63 assessments and 172 references.

Git Bash still resolves `python3` to the disabled Microsoft Store alias. WSL lists Ubuntu-24.04 but fails before VM startup with logon-right error `0x80070569`; Docker's Linux engine is stopped. Therefore the normal-user wrapper lifecycle, root refusal, unexpected-entry runtime refusal and cleanup execution remain unproved rather than inferred from static checks.

## Promotion blockers

Provider-backed local configurations, controlled provider installation and locks, representative state behavior, formal technical/security/instructional/accessibility review, browser integration, unseen learner transfer, delayed recall and safe supervised production transfer remain absent. No evidence here authorizes apply or proves general Terraform/OpenTofu compatibility.
