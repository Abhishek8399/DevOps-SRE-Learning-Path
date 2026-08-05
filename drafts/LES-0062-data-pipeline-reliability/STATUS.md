# LES-0062 draft status

Status: **substantive candidate and quarantined - not canonical, accepted, or mastery evidence**

## Candidate inventory

- Lesson: 7,563 words, one H1, 18 required H2 sections, and 60 H3 sections.
- Structured teaching objects: six diagrams, twelve command contracts, two labs, and five incident patterns.
- Assessments: ASM-0169 diagnostic (50 points), ASM-0170 production (100 points), and answer-isolated ASM-0171 independent transfer (100 points).
- Sources: fifteen primary or official reference records, REF-0688 through REF-0702.
- Offline model: eighteen deterministic branches covering source replay, stable positions, transform determinism, sink idempotency, checkpoint durability and compatibility, time, schema, quality, lineage, skew, drain capacity, privacy, and replay isolation.

## Verification completed on 2026-08-05

- Lesson, assessment, and reference records pass their direct structured-content schemas.
- All support JSON records parse.
- Python compilation and all eighteen expected model decisions pass on the Windows host.
- `lab.sh` and `verify.sh` pass Git Bash syntax checks and ShellCheck.
- The independent-transfer assessment contains no model-answer fields.
- The source records were resolved to their official or primary destinations during the source audit.

## Evidence boundary

The deterministic model is not Spark, Flink, Beam, a scheduler, broker, state backend, checkpoint store, data lake, catalog, lineage service, quality engine, external sink, or benchmark. It opens no socket and creates no real job, dataset, table, checkpoint, stream, effect, replay, load, or external resource.

Ubuntu 24.04 runtime execution is not claimed. WSL startup is blocked before the VM is created by `Wsl/Service/CreateInstance/CreateVm/HCS/0x80070569`: the user has not been granted the requested logon type. The guarded Ubuntu lifecycle therefore remains unexecuted.

Publication, formal review, representative engine/connector/storage/sink evidence, reviewer transfer, delayed recall, and learner evidence remain required.
