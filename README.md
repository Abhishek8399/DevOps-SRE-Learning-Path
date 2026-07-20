# DevOps/SRE Training Workspace

This directory holds the evidence and working artifacts for the interactive training program. The external `DevOps-SRE-Prompt.txt` remains the governing instruction source and is not copied into this repository.

## Current state

- Started: 2026-07-20
- Stage: adaptive onboarding through an embedded practical diagnostic
- Phase 1 status: gated pending diagnostic evidence
- Competency ratings: not yet assigned
- Delivery model: local-first; no online cloud resources
- Primary implementation stack: pending diagnostic evidence

## Workflow

1. Complete the first assessment batch in [assessments/initial-assessment.md](assessments/initial-assessment.md).
2. The mentor evaluates the response and records only evidence-supported changes in [progress/ledger.md](progress/ledger.md).
3. The diagnostic continues adaptively until prerequisites, unsafe misconceptions, and practical ability are sufficiently clear.
4. Phase 1 is then personalized and unlocked in [phase-01-foundations/README.md](phase-01-foundations/README.md).
5. Advancement requires explanation, implementation, verification, failure diagnosis, safety analysis, and later recall—not lesson completion alone.

## Evidence rules

- Submit explanations in your own words and identify any external help used.
- Include actual command output when requested; do not claim results from commands that were not run.
- Redact secrets, tokens, credentials, private URLs, tenant or subscription identifiers, and sensitive employer data.
- Separate facts, assumptions, hypotheses, and unverified claims.
- Do not perform a mutating action unless the exercise labels it `[MUTATING]` and provides scope, success criteria, and rollback.
- Production systems and employer cloud accounts are out of scope unless explicitly approved for a later exercise.

## Learner files

- [Learner profile](learner-profile.md)
- [Local environment baseline](environment/local-baseline.md)
- [Initial assessment](assessments/initial-assessment.md)
- [Progress ledger](progress/ledger.md)
- [Phase 1: Foundations](phase-01-foundations/README.md)
- [Active Lesson 1: Linux storage and ENOSPC triage](phase-01-foundations/lesson-01-linux-storage-enospc/README.md)
