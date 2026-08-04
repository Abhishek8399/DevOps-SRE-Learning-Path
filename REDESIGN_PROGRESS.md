# Redesign progress

Last updated: 2026-08-04

This tracker reports implementation evidence, not learner mastery.

| Area | State | Evidence or next gate |
|---|---|---|
| Repository and architecture audit | Complete | Routes, content registry/parser, shell, structured/legacy renderers, reader state, search, practice and test suites inspected |
| Current HTTP baseline | Complete | Local root returned 200 with expected title on port 3000 |
| Current rendered baseline | Blocked | Browser runtime discovery returned no available backend; no visual claim recorded |
| UI audit | Complete | `UI_AUDIT.md` |
| Design system | Complete | `DESIGN_SYSTEM.md` |
| Implementation plan | Complete | `REDESIGN_PLAN.md` |
| Semantic tokens and themes | Complete | Paper, night and sepia semantic tokens plus compatibility aliases and AA token ratios |
| Book shell and navigation | Complete | Independent persistent rails, hierarchical volumes, mobile drawers, focus trap and Escape return |
| Library and chapter openers | Complete | Main cover, personal shelf, seventeen volume identities and editorial volume/lesson entry |
| Manuscript and content components | Complete | Structured and legacy prose, code, tables, labs, assessments, incidents and references share the field-manual system |
| Reader preferences | Complete | Theme, size, leading, width, wrap, focus and rail state persist locally |
| Accessibility | In progress | Source/automated items recorded in ACCESSIBILITY_CHECKLIST.md; rendered checks blocked |
| Functional verification | Complete | Content, registry, 38 schema tests, 21 reader tests, lint, typecheck, build and representative HTTP routes pass |
| Visual QA | Blocked | Required viewports and themes await supported browser access |

## Current verification

- Content validation: 128 Markdown files, 21 structured lessons, 63 assessments and 172 references pass.
- Content schema: 38 pass, 1 environment-specific symlink test skips, 0 fail.
- Reader suite: 21 pass, 0 fail.
- TypeScript, ESLint and production build pass.
- HTTP 200: library, all five volume openers, search, My Learning, storage practice, a structured lesson and the legacy storage lesson.
- Browser discovery still exposes no in-app or Chrome backend. No screenshot, responsive-layout or visual-contrast claim is fabricated.

## Preserved parallel work

The uncommitted `LES-0036-resilience-patterns-failure-isolation` draft predates this redesign request. It is preserved without being promoted or bundled into redesign claims.
