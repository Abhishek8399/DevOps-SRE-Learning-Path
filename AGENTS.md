# Repository Instructions for AI and Engineering Agents

## Purpose

This repository is the durable, evidence-based workspace for an interactive DevOps, SRE, platform engineering, cloud architecture, security, distributed-systems, and AI operations training program.

The learner is not advanced because a lesson or file exists. Advancement must be supported by explanations, working implementations, verification output, failure diagnosis, safe-change reasoning, transfer exercises, and delayed recall.

## Sources of truth

- `README.md`: program entry point and current workflow.
- `learner-profile.md`: known, observed, and pending learner context.
- `assessments/`: assessment questions and submitted evidence.
- `progress/ledger.md`: competency, hints, confidence, errors, reviews, and next challenges.
- `phase-01-foundations/`: current phase gate and milestone status.

Read these files before proposing or changing training work. Do not infer mastery from job title, years of experience, vocabulary, or self-reported confidence.

## Working rules

- Make the smallest safe, reviewable change that advances the current assessed need.
- Keep facts, evidence-based inferences, assumptions, hypotheses, and unverified claims distinct.
- Never fabricate learner evidence, command output, test results, incidents, project experience, or resume metrics.
- Do not publish answer keys before the learner has attempted an exercise. Use progressive hints and record hints used.
- Do not unlock a phase or raise a competency level without recorded evidence.
- Update the learner profile, assessment status, ledger, and checkpoint when relevant evidence changes.
- Use current primary sources for version-sensitive claims and record what was verified.
- Prefer local, disposable, least-privilege labs. Never request or commit real credentials.
- Label exercise commands `[READ-ONLY]`, `[MUTATING]`, `[DESTRUCTIVE]`, or `[COST-INCURRING]`.
- Every substantial lab must define scope, prerequisites, success evidence, blast radius, rollback/recovery, and cleanup.
- Treat cloud, CI/CD, Terraform, Kubernetes, Docker, security, and production-operation changes as production-sensitive.

## Git workflow

- Work only in this repository for this training program.
- Inspect `git status --short` before and after changes.
- Validate the narrowest relevant artifacts before committing.
- Commit logically complete, validated training changes and push them to `origin/main` as requested by the repository owner.
- Never force-push, rewrite history, discard unrelated work, or push secrets.
- If authentication, remote divergence, failing validation, or an unsafe change blocks a push, stop and report the exact blocker.
