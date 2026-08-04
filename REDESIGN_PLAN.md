# Redesign implementation plan

## Work packages

1. Preserve and baseline: record Git state, route/state/content contracts and passing tests.
2. Foundation: semantic tokens, typography, paper/night/sepia themes, motion and focus rules.
3. Shell: coordinated desktop regions, collapsible navigator, context rail, mobile drawers and compact toolbar.
4. Library: primary cover, personal continuation, volume covers, bookmarks, recent study and journey map.
5. Chapter entry: memorable opener, progressive metadata and clear start/continue transition.
6. Manuscript: readable measure, editorial section rhythm, notes, figures and related navigation.
7. Technical components: code plates, responsive tables, commands, labs, incidents, assessments and references.
8. Preferences: theme, type size, line spacing, reading width, code wrapping, distraction-free mode and sidebar state.
9. Accessibility: semantics, drawer focus, escape behavior, live feedback, touch targets, reduced motion, zoom and print.
10. Verification: tests, lint, typecheck, build, HTTP routes, browser viewports/themes and final design audit.

## Change strategy

- Keep route and content data contracts unchanged.
- Introduce new shell/reader components beside existing renderers.
- Use compatibility tokens so legacy lessons improve immediately.
- Migrate the structured renderer first because it represents the long-term content system.
- Avoid new UI dependencies.
- Commit source redesign and evidence/documentation separately when each gate is clean.

## Acceptance evidence

Automated gates establish code and content integrity. Browser screenshots and interaction transcripts are required for visual claims. Until browser access exists, `VISUAL_QA.md` remains blocked rather than inferred from CSS.
