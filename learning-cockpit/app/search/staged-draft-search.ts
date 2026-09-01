import type { MarkdownInline } from "../lessons/structured-lesson-parser";
import type { StagedDraft } from "../staged-draft.server";
import type { SearchDocument } from "./search-index";

function unique(values: readonly string[]): string[] {
  return [...new Set(values.map((value) => value.trim()).filter(Boolean))];
}

function inlineText(inlines: readonly MarkdownInline[]): string {
  return inlines.map((inline) => inline.text).join("");
}

export function createStagedDraftSearchDocuments(
  drafts: readonly StagedDraft[],
): readonly SearchDocument[] {
  return drafts.map((draft) => {
    const { lesson } = draft;
    const metadata = lesson.metadata;
    const terms = lesson.sections.find((section) => section.title === "Terms before commands")
      ?.blocks.flatMap((block) => block.kind === "heading" ? [inlineText(block.content)] : []) ?? [];
    return {
      id: `draft-${metadata.id}`,
      kind: "chapter",
      number: metadata.id.slice(-4),
      volumeNumber: "99",
      volumeTitle: "Staged draft library",
      title: metadata.title,
      subtitle: `Staged preview: ${metadata.summary}`,
      href: `/drafts/${draft.slug}`,
      fields: [
        { category: "Lesson ID", values: [metadata.id, metadata.slug, ...metadata.aliases, ...metadata.curriculumIds], weight: 16 },
        { category: "Title", values: [metadata.title, metadata.summary], weight: 14 },
        { category: "Incident signal", values: unique(metadata.productionSignals), weight: 11 },
        { category: "Command", values: unique(metadata.commands.flatMap((command) => [command.command, command.question])), weight: 9 },
        { category: "Term", values: unique([...terms, ...metadata.diagrams.flatMap((diagram) => [diagram.title, ...diagram.boundaries, ...diagram.evidencePoints])]), weight: 8 },
        { category: "Lesson guidance", values: unique([...metadata.learningObjectives, ...metadata.limitations, "Staged draft preview; not canonical, runtime-validated, or mastery evidence."]), weight: 4 },
      ],
    };
  });
}
