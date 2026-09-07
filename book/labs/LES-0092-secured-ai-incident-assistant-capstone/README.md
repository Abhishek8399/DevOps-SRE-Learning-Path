# CAP-005 secured AI incident-assistant harness

This is a deterministic local security and evaluation harness. It does **not** call an AI model, model provider, network service, observability backend, shell, subprocess, cloud, Kubernetes, ticketing, chat or production API.

## What it demonstrates

- strict synthetic incident, telemetry, corpus, release, policy and evaluation contracts;
- sanitization before retrieval or generation;
- tenant/service authorization before a document can ground a claim;
- an explicitly untrusted candidate-generator boundary;
- material-claim and citation verification;
- typed narrow tools with authorization outside generator text;
- digest-bound, expiring, single-use approval for synthetic mutation;
- ambiguous-outcome reconciliation;
- privacy-aware hash-chained audit;
- critical-failure gates, independent kill and deterministic fallback;
- exact project ownership and cleanup.

The default generator is intentionally a scripted hostile fixture. This makes attacks reproducible and proves orchestration invariants. It does not measure a real model or establish production safety.

## Safe lifecycle

Run from this directory with Python 3.12 or newer:

```bash
python -m unittest discover -s tests -v
python assistantctl.py check
python assistantctl.py initialize
python assistantctl.py baseline
python assistantctl.py scenario prompt-injection
python assistantctl.py cleanup
python verify.py
```

`python verify.py` is the complete absent-to-absent evaluation. It refuses root on POSIX, validates project identity, runs every scenario, builds a dossier, checks expected decisions and proves cleanup.

## Decision vocabulary

| Result | Meaning |
|---|---|
| `pass` | The bounded baseline satisfied implemented evidence and authority invariants. |
| `blocked` | An unsafe, unsupported, leaking, stale or unauthorized path was refused before effect. |
| `fallback` | Model-assisted work was disabled or unreliable; deterministic evidence guidance remains. |
| `ambiguous` | A synthetic action was accepted but completion is unknown; reconcile before retry. |

These results describe this fixture only. They do not prove real-model quality, incident competence, production authority or mastery.

## Safety boundary

- Inputs are the six allowlisted JSON files in this directory.
- Only synthetic narrow identifiers and data are accepted.
- Runtime writes stay below descriptor-gated `.runtime`.
- Unknown files, symlinks, descriptor mismatch and audit damage block cleanup or mutation.
- No arbitrary command, URL, path or provider capability exists.
- An expected refusal is evidence, not a test failure.
