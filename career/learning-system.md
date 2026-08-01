# Local Learning Field Manual

## Recommendation

Build a lightweight documentation website backed by this Git repository. It should feel like an engineer's field manual: fast to scan, rich in small diagrams, and able to switch from explanation to lab, recall, incident, and interview modes without loading a graphics-heavy course.

## Source-of-truth model

```text
Git repository (durable)
|-- lessons and diagrams
|-- runnable local labs
|-- role requirement matrix
|-- reviewed learner evidence
|-- competency ledger and review dates
`-- website source
          |
          v
local website (teaching interface)
|-- read and navigate
|-- quiz and rehearse
|-- draft a teach-back in localStorage
`-- show the next due practice
```

The repository is durable because it can be cloned, reviewed, and understood by a future mentor or AI. The browser is an interface, not the authoritative record.

## Chapter pattern

Every topic should use the same compact sequence:

1. **Mental model:** one memorable explanation and one system diagram.
2. **Signals:** what the engineer sees and what each signal does or does not prove.
3. **Safe commands:** exact-path, read-only evidence before mutation.
4. **Lab:** a disposable failure with scope, success evidence, rollback, and cleanup.
5. **Teach-back:** explain the mechanism in plain technical language.
6. **Interview defense:** handle ambiguity, safety, and production trade-offs.
7. **Transfer:** solve a changed version without copying the original steps.
8. **Review:** revisit after increasing delays.

## Persistence boundaries

| Information | Storage | Durable after fresh clone? | Counts as mastery evidence? |
|---|---|---:|---:|
| Lessons, diagrams, labs, rubrics | Git | Yes | No |
## Five-lesson delivery cadence

Learning content is released in coherent groups of five lessons. Each group should follow prerequisite order and contain enough explanation to study independently from the website.

The learner reads at their own pace and asks whenever a section is unclear. The mentor answers the gap, adds durable clarification to the book, and avoids repetitive conversational quizzes. Optional self-checks remain available inside each lesson.

Competency gates remain smaller than content batches. Reading five lessons does not unlock five skills. Practical evidence, safe decisions, transfer, and delayed recall are reviewed at the point where they matter.

| Browser draft or flashcard state | `localStorage` | No | No |
| Submitted command output and written response | Repository evidence file | Yes | After review |
| Competency level and next review | `progress/ledger.md` | Yes | Yes, when evidence-supported |

A static browser page cannot safely commit and push on the learner's behalf. A later localhost-only companion service may export or write a narrowly scoped evidence file, but it must require an explicit action, validate paths, avoid secrets, and never raise mastery automatically.

## Performance constraints

- Prefer text, CSS, and small inline diagrams.
- Avoid video backgrounds, large image bundles, animation frameworks, analytics, and external fonts.
- Keep normal learning available without cloud accounts or external APIs.
- Bind the development server to loopback.
- Treat a dependency audit as unresolved until registry-backed evidence is available.

## Teaching control

The site may recommend the next topic from the ledger and due reviews. It must not unlock a new phase merely because a button was clicked. Advancement still requires reviewed explanation, implementation, verification, diagnosis, safety reasoning, transfer, and delayed recall.
