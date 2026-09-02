# UI audit: The Engineer's Field Manual redesign

Date: 2026-08-04

Last evidence update: 2026-09-02

Status: source and HTTP audit complete; rendered browser inspection blocked because no browser backend is currently exposed.

## What already works and must survive

- Next/Vinext application with stable routes for the library, five volume indexes, twenty-six lessons, search, My Learning and storage practice.
- Schema-backed content parser and generated registry with legacy compatibility.
- Local-only bookmarks, recent history and finished-reading markers that do not award mastery.
- Answer-isolated assessments, expandable teaching answers, labs, command copying, responsive tables, print rules and keyboard-visible focus.
- Content, schema and reader tests plus lint, typecheck and production build gates.
- Server-rendered long-form content with no dependency on a hosted API.

## Current experience problems

### Reading hierarchy

- A long lesson sits inside a wide elevated card, so the container competes with the manuscript.
- Body prose is frequently below comfortable long-form size and can span close to 980 px.
- The lesson opener exposes metadata, prerequisites and all subsection links before the reader reaches the argument.
- Many content types use equally weighted bordered cards; meaning is carried by container density rather than editorial rhythm.
- Uppercase micro-labels are overused and create visual noise.

### Navigation and shell

- Desktop navigation permanently renders every available lesson and uses 286 px even when the reader knows where they are.
- Volume, chapter and lesson hierarchy exists in data but is visually flattened into a long list.
- Mobile navigation uses one large `details` block instead of a focused, dismissible drawer.
- There is no independent contextual rail; subsection navigation is a sticky horizontal strip that becomes another toolbar.
- The manuscript does not recenter when navigation disappears.

### Controls and state

- Reader controls are globally fixed at the bottom-right and can cover content or compete with interactive elements.
- Preferences support only two themes and three coarse text sizes.
- Line spacing, manuscript width, code wrapping, distraction-free mode, navigation state and context-rail state are implemented as browser-local preferences; real-browser persistence and interaction review remain open.
- Theme-specific colours are repeated in component styles rather than expressed through complete semantic tokens.

### Library and chapter entry

- The root page reads partly like a product landing page and the library like a card dashboard.
- Volume cards do not yet behave like a coherent set of book covers.
- Continue reading, recent history and bookmarks are separated on My Learning rather than making the library feel alive.
- Chapter openers are technically complete but visually similar to the rest of a lesson.

### Technical content

- Structured code blocks now distinguish command, configuration, terminal transcript, expected output, source and diagram roles; support explicit safe filename labels and optional line numbers; and expose copy plus persistent wrap/scroll controls. A browser visual, keyboard and screen-reader review remains open.
- Tables work but do not provide a caption from structured content and use a heavy dark header.
- Answer cards, command cards, labs and incidents are functionally strong but visually dense.
- Legacy and structured lessons use different visual grammars.

### Accessibility and performance risks

- Existing skip link, focus styles, semantic headings and live announcements are valuable.
- Mobile drawer semantics, escape-to-close, focus return and body-scroll behavior need implementation.
- Multiple sticky elements can collide.
- Some uppercase labels and small text fall below comfortable reading sizes even when contrast passes.
- External font loading would weaken offline behavior and cause layout shifts; the redesign should use local/system fallbacks unless font files are vendored.

## Root cause

The application grew by adding good learning capabilities into separate surfaces. Styling optimized each capability as a panel or card. The result is feature-complete but visually reads as a documentation dashboard. The redesign must establish one book shell and one editorial hierarchy, then let existing capabilities inherit it.

## Preservation boundary

Do not change stable routes, content IDs, registry generation, schema contracts, mastery boundaries, answer isolation or saved-learning schema merely for appearance. Add reader preferences under separate namespaced keys. Any note text must remain browser-local, bounded and clearly warn against secrets or production data.

## Audit evidence

- `http://127.0.0.1:3000/` returned HTTP 200 and the expected title.
- Source inspection covered root/book layouts, navigation, reader controls, library and home pages, routed lesson composition, structured renderer, legacy renderer, search, My Learning state and reader tests.
- Current browser discovery returned no available backend. No screenshot, pixel, focus-order or viewport claim is made until a supported browser becomes available.

## Interview-practice improvement evidence

- All 29 timed scenarios expose topic, difficulty and expected level before response entry, covering expected levels from Junior through Architect and reducing ambiguity about the expected answer depth.
- The answer reveal separates the strong answer, why the reasoning works, a concrete production example, weak-answer warning signs and senior follow-ups instead of presenting one undifferentiated paragraph.
- The metadata uses a compact semantic definition list and collapses from three columns to one below 620 px; the warning panel uses existing theme-aware semantic tokens.
- Type, lint, reader and production-build checks pass, and loopback HTML contains every layer for the initial scenario. Browser visual hierarchy, disclosure interaction, screen-reader output, mobile layout and keyboard focus remain unverified because no browser backend is connected.

## Structured code-block evidence

- Fence metadata accepts only six documented roles, bounded traversal-free repository-style file labels and `lines=on|off`; unknown or malformed attributes fail closed with focused parser diagnostics.
- Existing blocks retain conservative language-based labels. Canonical examples now explicitly mark a runnable Bash block, a line-number-free expected-output sample, Dockerfiles and four named CI definitions.
- All non-diagram blocks expose copy and wrap/scroll actions; the global preference is restored from browser-local storage before paint. Diagrams suppress both actions and line numbers to keep the figure visually quiet.
- Thirty-five reader tests, content/registry/plan validation, typecheck, lint, all five production-build stages, web-budget and hygiene gates pass. Representative canonical routes return HTTP 200 with role, filename, wrap and copy markup. Browser interaction and visual quality remain unverified because no browser backend is connected.
