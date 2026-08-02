# Structured content contract

This directory defines the machine-readable contract for the field manual. It exists so a lesson remains understandable to a learner, renderable by the local site, reviewable in Git, and inspectable by a future human or AI without relying on chat history.

## Version 1 decision

Version 1 lessons use non-executable Markdown with a JSON object between the opening and closing front-matter delimiters:

```markdown
---
{
  "schemaVersion": 1,
  "kind": "lesson",
  "id": "LES-0006",
  "aliases": ["V01-L06"],
  "curriculumIds": ["LNX-005"]
}
---
```

JSON is deliberately used inside the front matter. It is valid YAML, but the repository can parse it deterministically with Node.js and no YAML dependency. This prevents silent coercion of dates, booleans, and numbers.

The portable JSON Schema record files are:

- `lesson.schema.json` — lesson metadata, diagrams, command evidence, lab boundaries, and cross-record links;
- `assessment.schema.json` — answered questions, answer-isolated independent transfer, evidence, and scoring;
- `reference.schema.json` — versioned primary-source ownership and review metadata;
- `legacy-content-map.json` — permanent identity reservations for the five published typed lessons.

`verified-chapter` is intentionally not a schema-v1 author value. A lesson may advance only to `review-required` until a subject-bound technical, instructional, safety, and evidence review contract is implemented. A generic project check or an author-entered verification ID is not chapter acceptance.

The repository validator first audits every supported schema keyword and local reference, then compares each schema to a reviewed policy digest and enforces relationships that a single record cannot prove: identity reservations, unique IDs, resolved prerequisites, self-dependency refusal, exact paths and filenames, assessment-domain ownership, review-date ordering, backlinks, cycles, lab containment, canonical-tree symlink refusal, and rubric totals. Unknown keywords, malformed keyword values, and unreviewed policy weakening fail closed.

## Canonical locations

```text
book/
|-- volumes/<volume-slug>/<lesson-id>-<slug>/lesson.md
|-- assessments/<domain>/<assessment-id>.json
|-- references/<reference-id>.json
`-- schema/
```

Existing TypeScript lessons remain authoritative until a separately reviewed typed-to-structured-Markdown migration. Adding this contract must not change their URLs, IDs, text, or learner state.
The five typed lessons are reserved in `legacy-content-map.json` as `LES-0001` through `LES-0005`. The validator checks every mapped source file and compares the complete identity set to an independently pinned SHA-256 baseline, permanently reserving their routes, slugs, aliases, and curriculum mappings. New content cannot reuse those identities. A migrated record is accepted only when it preserves the complete reserved identity. Source paths may move during a reviewed migration; published identities may not.

`LES-0006` is the first schema-backed lesson. The current authored corpus contains twenty structured `substantive-draft` lessons (`LES-0006` through `LES-0025`) across Volumes 00 through 03, 60 assessments—forty complete-answer records and twenty answer-isolated independent transfers—and 163 references. Together with the five reserved typed lessons, the reader exposes twenty-five routed identities. Use the next unused opaque IDs for new work: `LES-0026`, `ASM-0061`, and `REF-0164` at this checkpoint. An ID is permanent once published and is never recycled. Schema validity and publication do not constitute formal chapter acceptance, provider execution, or learner mastery.


## Identity rules

Canonical record identity is deliberately independent of taxonomy and navigation:

| Concept | Example | Rule |
|---|---|---|
| Lesson ID | `LES-0001` | Opaque, immutable, and never reused |
| Assessment ID | `ASM-0001` | Opaque, immutable, and owned through `lessonId` |
| Reference ID | `REF-0001` | Opaque, immutable, and reusable |
| Curriculum domain | `LNX-005` | Existing `CONTENT_MATRIX.md` identity; several lessons may map to one domain |
| Public alias | `V01-L06` | Preserved after publication |
| Route | `/book/linux/boot-kernel-systemd-journal` | Explicit and never derived from the directory |

Child diagrams, commands, labs, and incidents extend the lesson ID, for example `LES-0001-CMD-001`. A slug or volume may change with a redirect; the lesson ID never changes. This separation matters because the existing request-path lesson is routed under Linux but maps to several `NET-*` domains.

Prerequisites may use migrated lesson IDs and canonical curriculum IDs in separate fields. They never use titles or URLs. Assessment, incident, lab, diagram, command, and reference links are explicit IDs so broken relationships fail validation.

Reader prerequisite navigation is advisory. A declared lesson ID may resolve only through the trusted catalog; it must never be used to lock a lesson, auto-mark completion, or infer competency. Missing or invalid prerequisite identities fail closed instead of producing a guessed path.

Assessment files live under the same domain as their owning lesson. For example, an assessment owned by a lesson whose domain is `linux` belongs in `book/assessments/linux/`.

Answered assessment types contain the complete direct, foundation, reasoning, senior, weak-answer, evidence, and follow-up fields. An `independent-transfer` record does the opposite: it declares deliverables, required learner evidence, and `reviewer-only-no-model-answer`, while model-answer fields are forbidden. This keeps the unfamiliar attempt answer-isolated. A rubric can describe observable evidence, but passing it still requires an explicit human or authorized reviewer decision and never follows from reading or answer reveal.

## Required lesson body sections

A schema-valid metadata block is not a complete lesson. Each structured lesson body must contain these level-two headings:

1. `What you see and first thought`
2. `Terms before commands`
3. `Architecture map`
4. `Request or state path`
5. `Failure zoom`
6. `Internals and state ownership`
7. `Evidence table`
8. `Command decoders`
9. `Decision path`
10. `Guided Ubuntu lab`
11. `Production transfer`
12. `Reliability, security, observability, capacity, and cost`
13. `Traps and prevention`
14. `Memory card and retrieval`
15. `Complete answers`
16. `Product-company interview`
17. `Independent transfer and rubric`
18. `References and review`

Headings are deliberately stable machine anchors. Friendly subheadings may be added underneath them.

Schema-v1 lesson Markdown cannot contain raw HTML blocks or HTML comments. This keeps structural headings deterministic and prevents markup from looking like a real section to one parser but raw text to another. Literal markup remains valid inside fenced code blocks.
Every required section must contain visible explanatory content; headings alone are rejected.

## Evidence and safety boundaries

Every command answers an explicit question and declares:

- its risk class;
- the exact command;
- the namespace or environment where it runs;
- expected branches and the next evidence for each branch;
- what it proves;
- what it cannot prove.

A command risk label is an author assertion, not proof. The validator rejects obvious mutators such as `rm`, mutating `systemctl`, package installation, or `terraform apply` when labeled read-only. Shell behavior cannot be proven completely with token matching, so every command still requires subject-bound safety review before chapter acceptance.

Every lab declares privilege, network access, changed resources, abort conditions, recovery, and cleanup proof. An external lab path is optional, but when present it must resolve to a dedicated directory under one of these reviewed roots:

- `phase-##-*/<lab>/`
- `labs/<lab>/`
- `book/labs/<lab>/`

The validator rejects files, repository root, `.git`, traversal, drive paths, backslashes, colons, case drift, and symlink or junction escape. A lab realpath must remain inside the exact selected phase, `labs`, or `book/labs` root. A mutating lab is not publishable merely because its happy path works.

Reference URLs must use their exact canonical HTTPS serialization and cannot contain raw control/space characters, embedded credentials, queries, or fragments. Store a durable canonical source page, never a normalized lookalike, signed URL, or session-bearing URL.

The schemas maintain three separate states:

```text
content published
      !=
reader marked finished
      !=
learner demonstrated mastery
```

A lesson or answer key never raises learner competency. Mastery requires sanitized learner-operated evidence, rubric review, and an explicit ledger update.

## Known version-1 boundary

The validator resolves lesson prerequisites, rejects lesson cycles, and rejects a lesson that names one of its own curriculum IDs as a prerequisite. It does not yet construct a complete prerequisite graph from every range expression in `CONTENT_MATRIX.md`, such as `LNX-001..007`. That matrix-wide cycle gate remains planned work; contributors must review those ranges manually until it exists.

This limitation does not weaken record identity, relationship, or lesson-cycle checks and does not permit a chapter to claim verified status.

## Schema evolution

Version 1 is strict: unknown fields fail validation so misspellings cannot disappear silently.

For a breaking change:

1. add the new schema and validator support, update the reviewed schema-policy digest, and keep the old reader until compatibility is proven;
2. add valid and invalid fixtures for both versions;
3. migrate one lesson and compare its route, content, links, and search record;
4. provide redirects or adapters where public slugs change;
5. migrate remaining records;
6. remove old support only after repository-wide validation and a recorded decision.

Never edit a published record in place merely to satisfy a new schema version. Preserve its stable ID and document the migration.

## Commands

From `learning-cockpit/`:

```bash
npm run validate:content
npm run test:content-schema
```

The first command validates live repository content. The second proves both acceptance and rejection behavior with controlled fixtures.
