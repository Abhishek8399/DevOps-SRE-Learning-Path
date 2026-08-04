# Design system: The Engineer's Field Manual

## Experience principles

1. Manuscript first: prose owns the visual centre and side tools recede.
2. Evidence has shape: warning, definition, command, result, decision and assessment must be distinguishable without turning every paragraph into a card.
3. Calm density: reduce borders, uppercase labels and simultaneous choices.
4. Durable offline reading: no remote runtime dependency, no surprise network request and no layout shift from web fonts.
5. Progress is not mastery: reading state stays visibly separate from reviewed evidence.

## Typography

- Prose: `"Source Serif 4", "Iowan Old Style", "Palatino Linotype", Georgia, serif`.
- Interface: `Inter, Manrope, ui-sans-serif, system-ui, sans-serif`.
- Code: `"JetBrains Mono", "Cascadia Code", "SFMono-Regular", Consolas, monospace`.
- Default manuscript: 18 px, 1.74 line height, 720 px measure.
- Compact/comfortable/large: 16.5/18/20 px.
- Narrow/standard/wide measures: 640/720/800 px.
- Headings use editorial serif with restrained negative tracking; labels use sentence case unless a short artifact ID requires capitals.

## Semantic tokens

Core tokens:

- `--page-background`, `--book-surface`, `--surface-subtle`, `--surface-raised`
- `--ink-primary`, `--ink-secondary`, `--ink-tertiary`, `--ink-inverse`
- `--accent-primary`, `--accent-primary-strong`, `--accent-secondary`
- `--border-subtle`, `--border-strong`, `--focus-ring`
- `--code-background`, `--code-surface`, `--code-ink`, `--code-muted`
- `--note-background`, `--warning-background`, `--success-background`, `--danger-background`
- `--shadow-soft`, `--shadow-raised`
- `--manuscript-width`, `--prose-size`, `--prose-leading`

Compatibility aliases map existing `--ink`, `--muted`, `--paper`, `--panel`, `--line`, `--navy`, `--teal` and `--orange` to the new semantics while legacy components migrate.

## Themes

- Paper: warm ivory page, lighter book surface, near-black ink, muted evergreen and ochre.
- Night: neutral charcoal page, slightly lighter manuscript surface, warm off-white ink and reduced-glare accents.
- Sepia: parchment page, warm cream surface, brown-grey ink and restrained moss/amber accents.

No information depends on colour alone. Focus uses a visible two-tone outline. Theme selection is stored locally and restored before paint.

## Layout

- Desktop shell: collapsible 272 px navigator, centred flexible manuscript, optional 248 px context rail.
- The manuscript remains centred within the available viewport using an inner `--manuscript-width`.
- At 1180 px the context rail becomes an overlay/drawer; at 980 px the navigator becomes a modal drawer.
- Page-level horizontal scrolling is forbidden; code and large tables own their overflow.
- Sticky chrome uses one coordinated top offset.

## Editorial components

- Chapter opener: volume folio, chapter number, title, deck, outcomes, prerequisites and reading/lab facts.
- Running header: breadcrumb, progress and compact tools.
- Definition: subtle left rule and term-first typography.
- Production warning: amber rule, direct consequence and safe next action.
- Reliability/security/cost notes: semantic icon plus label, never colour alone.
- Figure: caption, flow or diagram, text alternative and evidence points.
- Code plate: role/language, optional filename, copy, wrap and optional line numbers.
- Table: caption, quiet header, sticky header only when long, first-column emphasis.
- Assessment: question first; answer hidden; calm feedback and deep explanation after intent.
- Lab: objective, requirements, steps, expected result, validation, cleanup and troubleshooting.
- References: editorial bibliography rather than a card grid.

## Motion

Use 140-220 ms opacity/transform transitions for drawers, settings, accordions and confirmations. Disable nonessential motion under `prefers-reduced-motion`. Never animate the manuscript continuously.
