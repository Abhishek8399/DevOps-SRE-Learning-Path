# DevOps/SRE Training Workspace

This directory holds the evidence and working artifacts for the interactive training program. The external `DevOps-SRE-Prompt.txt` remains the governing instruction source and is not copied into this repository.

All teaching sessions must follow the [conversation and diagram style](TEACHING-STYLE.md): practical engineer-to-engineer explanation, memorable mental models, precise connectivity diagrams, and one focused checkpoint at a time.

The [target-role requirements matrix](career/target-role-matrix.md) maps the supplied Apple, Experian, Mastercard, Cisco, Visa, GitLab, NVIDIA, Arm, and ADP roles to a shared engineering foundation and specialist tracks. The [local learning field manual design](career/learning-system.md) defines how the website, labs, Git evidence, and competency ledger work together.

## Current state

- Started: 2026-07-20
- Stage: Phase 1 guided Linux foundations and practical assessment
- Phase 1 status: active; storage remediation remains the current evidence gate
- Competency ratings: Linux storage diagnosis is L1; other areas remain unassessed
- Delivery model: local-first; no online cloud resources
- Primary implementation stack: Ubuntu 24.04 in WSL 2, Docker only for isolated failures, and the local field-manual website

## Workflow

On Windows, run `startlearning.cmd`; on Ubuntu/WSL, run `bash startlearning.sh`. Both check for Node.js and installed dependencies, then bind the reader only to `127.0.0.1:3000`. Stop it with `Ctrl+C`; neither creates a background service.

Manual equivalent:

```powershell
Set-Location learning-cockpit
npm ci
npm run dev -- --hostname 127.0.0.1 --port 3000
```

1. Launch the local field manual from [learning-cockpit](learning-cockpit/README.md) and follow the current lesson path.
2. Read the prerequisite vocabulary, system picture, and field-by-field output decoder before running a command.
3. Run only the bounded Ubuntu or isolated lab stated by the lesson and preserve the requested output.
4. The mentor reviews submitted evidence and records only supported changes in [progress/ledger.md](progress/ledger.md).
5. Advancement requires explanation, implementation, verification, failure diagnosis, safety analysis, transfer, and later recall; reading completion alone is never enough.

## Evidence rules

- Submit explanations in your own words and identify any external help used.
- Include actual command output when requested; do not claim results from commands that were not run.
- Redact secrets, tokens, credentials, private URLs, tenant or subscription identifiers, and sensitive employer data.
- Separate facts, assumptions, hypotheses, and unverified claims.
- Do not perform a mutating or destructive action unless the exercise labels it `[MUTATING]` or `[DESTRUCTIVE]` and provides exact scope, stop conditions, success evidence, and cleanup or rollback.
- Production systems and employer cloud accounts are out of scope unless explicitly approved for a later exercise.

## Learner files

- [Learner profile](learner-profile.md)
- [Teaching and diagram style](TEACHING-STYLE.md)
- [Local environment baseline](environment/local-baseline.md)
- [Initial assessment](assessments/initial-assessment.md)
- [Progress ledger](progress/ledger.md)
- [Target-role requirements matrix](career/target-role-matrix.md)
- [Interview mastery playbook](career/interview-playbook.md)
- [Incident communication playbook](career/incident-communication-playbook.md)
- [Platform engineering primer](career/platform-engineering-primer.md)
- [Cloud architecture primer](career/cloud-architecture-primer.md)
- [DevSecOps and supply-chain primer](career/devsecops-supply-chain-primer.md)
- [Distributed-systems primer](career/distributed-systems-primer.md)
- [Data-systems primer](career/data-systems-primer.md)
- [Hybrid-connectivity primer](career/hybrid-connectivity-primer.md)
- [Observability primer](career/observability-primer.md)
- [SLO primer](career/slo-primer.md)
- [Book architecture and knowledge map](book/README.md)
- [Lesson and Ubuntu lab standard](book/LESSON-STANDARD.md)
- [Field-manual contribution workflow](book/CONTRIBUTING.md)
- [Local learning field manual design](career/learning-system.md)
- [Local visual learning cockpit](learning-cockpit/README.md)
- [Phase 1: Foundations](phase-01-foundations/README.md)
- [Active Lesson 1: Linux storage and ENOSPC triage](phase-01-foundations/lesson-01-linux-storage-enospc/README.md)
