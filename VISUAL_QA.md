# Visual QA

Current state: **automated and HTTP verification complete; rendered visual review blocked**.

The development server responds at http://localhost:3000/, but browser runtime discovery returned no available in-app or Chrome backend on 2026-08-04, including after the redesigned server was restarted. No screenshot or viewport result is inferred from source code.

## Required matrix

Viewports:

- 1440 x 900
- 1280 x 800
- 1024 x 768
- 768 x 1024
- 390 x 844

Surfaces:

- library
- volume/chapter opener
- long structured lesson
- code-heavy lesson
- table-heavy lesson
- guided lab
- answered and answer-isolated assessment
- storage practice quiz/interview
- search with empty, result and no-result states
- My Learning with empty and populated state

States:

- paper, night and sepia
- both desktop rails open, each independently collapsed and distraction-free
- mobile navigation and context drawers
- code wrapped and unwrapped
- default, large type, increased leading and narrow measure
- keyboard focus, 200 percent zoom, reduced motion and print preview

## Review questions

For every matrix sample check page-level overflow, clipped text, manuscript centring, line length, sticky collisions, drawer focus, contrast, code readability, table behavior, touch targets, empty states, motion and content coverage.

## Evidence log

| Date | Viewport and state | Surface | Result | Screenshot | Fix |
|---|---|---|---|---|---|
| 2026-08-04 | Browser unavailable | Baseline discovery | Blocked | None | Retry supported browser connection before acceptance |
| 2026-08-04 | HTTP, viewport-independent | Root, library, five volumes, search, My Learning, practice | Pass: HTTP 200 and no transform-error marker | Not applicable | None |
| 2026-08-04 | HTTP, viewport-independent | Structured systems-thinking lesson | Pass: HTTP 200, 1,821,279 bytes, no transform-error marker | Not applicable | None |
| 2026-08-04 | HTTP, viewport-independent | Legacy storage lesson | Pass: HTTP 200, expected heading, no transform-error marker | Not applicable | None |
| 2026-08-11 | In-app browser connector | Home and representative lesson routes | Blocked: connector reports `No browser is available`; local HTTP server responds 200 | None | Retry screenshot, keyboard, zoom, theme and mobile matrix when a supported browser is available |
| 2026-09-02 | HTTP, viewport-independent | Enriched timed interview practice | Follow-up pass: initial request preceded server readiness; retry returned 200 with topic, difficulty, expected level, layered answer guidance and weak-answer warnings | Not applicable | Browser disclosure, responsive and keyboard review remains open |
| 2026-09-02 | HTTP, viewport-independent | Invalid canonical lesson recovery | Pass: HTTP 404 with recovery title, library/search/extended links and explicit unchanged-state copy | Not applicable | Browser error injection, retry, focus, screen-reader and viewport review remains open |

## Automated evidence

- Production build completes across every application route.
- ESLint and TypeScript complete with zero diagnostics.
- Paper, night and sepia primary, secondary and accent token pairs measure between 5.03:1 and 14.56:1.
- Source contracts prevent page-level horizontal overflow; code and tables own local overflow.
- Responsive breakpoints exist at 1180, 1100, 980, 780, 700, 680, 600, 480 and related legacy component thresholds.

These checks reduce risk but do not replace the required screenshot, keyboard, zoom and print-preview matrix.
