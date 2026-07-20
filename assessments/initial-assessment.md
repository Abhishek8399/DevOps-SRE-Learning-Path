# Initial Assessment

Date opened: 2026-07-20
Status: onboarding response in progress; diagnostic awaiting learner response
Mode: closed-notes and AI-free unless explicitly disclosed

## Submission rules

- Reply in chat using the question numbers below.
- Do not search for the diagnostic answer or use AI for it.
- If you do use a source or tool, identify exactly what you used.
- State uncertainty directly. A well-calibrated uncertain answer is better evidence than an unsupported confident answer.
- Do not run mutating commands against a real system for this assessment.

## Onboarding batch 1

1. May Phase 1 use WSL 2 Ubuntu 24.04 as the primary lab environment? Provide RAM, usable free disk, whether Docker Desktop/WSL integration works, and any installation or employer restrictions.
2. Choose one primary cloud for deep study—Azure, AWS, or GCP—and state whether labs must be free-only or your maximum monthly budget. Mention any existing non-production access.
3. For Bash, Python, PowerShell, and Go, give a confidence score from 0–100 and one recent automation task you personally implemented or debugged. Use `none` where applicable.
4. List the infrastructure, CI/CD, container, Kubernetes, observability, security, database, and cloud tools you have operated. Distinguish independent production ownership from assisted use or lab-only exposure.
5. List certifications and defensible projects, then name your three strongest and three weakest technical areas. `None` or `unknown` is acceptable.
6. Choose a usual session length (30, 60, 90, or 120 minutes), preferred explanation language, and whether you can periodically complete closed-notes, AI-free exercises.

## Onboarding response status

| Question | Status | Recorded evidence or remaining gap |
|---:|---|---|
| 1 | Partially answered and locally verified | WSL 2 Ubuntu 24.04 approved; installation permitted; CPU, RAM, disk, systemd, and Docker state verified. Employer, proxy, network, and reboot restrictions remain pending. |
| 2 | Scope decision recorded | Local-only delivery confirmed; no online cloud resources. Provider-specific target is deferred. |
| 3 | Pending | Scripting confidence and owned automation example required. |
| 4 | Pending | Tool-operation depth and ownership evidence required. |
| 5 | Pending | Certifications, defensible projects, strengths, and weaknesses required. |
| 6 | Pending | Session length, language, and AI-free practice availability required. |
| Diagnostic problem 1 | Pending | No reasoning response submitted yet. |

## Evidence coverage tracker

No capability score is assigned until evidence exists.

| Required diagnostic evidence | Status |
|---|---|
| Short factual questions | Pending |
| Conceptual “how and why” questions | Pending |
| Command-output interpretation | Pending |
| Incomplete-evidence debugging | Started below |
| Architecture with competing requirements | Pending |
| Production safety and rollback | Started below |
| Assumptions and confidence calibration | Started below |
| Small scripting exercise | Pending |
| Flawed AI-generated answer audit | Pending |

## Diagnostic problem 1 — misleading disk evidence

Timebox: 10–15 minutes. Do not execute commands; reason from the supplied evidence.

A production Linux API cannot accept uploads. The first relevant application error at 10:04 is:

```text
OSError: [Errno 28] No space left on device: '/var/lib/api/uploads/7f9c.tmp'
```

An operator provides:

```text
$ df -h /var
Filesystem              Size  Used Avail Use% Mounted on
/dev/mapper/vg-var       40G   18G   20G  48% /var
```

The last deployment completed at 09:50. CPU and memory dashboards appear normal. You may not restart services, delete files, remount filesystems, or change production state without approval.

Using the FRAME method, provide one concise response containing:

1. Known facts separated from assumptions.
2. At least three ranked hypotheses.
3. Your first three `[READ-ONLY]` checks, in order. For each, predict what it could show and how that result would change the ranking.
4. The safest next move after those checks, including required authorization, success/abort criteria, and rollback or recovery thinking.
5. Your confidence from 0–100% and the most important missing evidence.
