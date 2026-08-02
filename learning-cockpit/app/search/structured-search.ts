import type {
  MarkdownInline,
  StructuredLessonBundle,
} from "../lessons/structured-lesson-parser";
import { getReaderVolume } from "../lessons/reader-catalog-core.ts";
import type { SearchDocument } from "./search-index";

function unique(values: readonly string[]): string[] {
  return [...new Set(values.filter((value) => value.trim().length > 0))];
}

function inlineText(inlines: readonly MarkdownInline[]): string {
  return inlines.map((inline) => inline.text).join("");
}

export function createStructuredSearchDocument(
  bundle: StructuredLessonBundle,
): SearchDocument {
  const { lesson } = bundle;
  const metadata = lesson.metadata;
  const volume = getReaderVolume(metadata.volume);
  const termsSection = lesson.sections.find((section) =>
    section.title === "Terms before commands");
  const sectionTerms = termsSection?.blocks.flatMap((block) =>
    block.kind === "heading" ? [inlineText(block.content)] : []) ?? [];

  return {
    id: metadata.id,
    number: String(metadata.order).padStart(2, "0"),
    volumeNumber: volume.volumeNumber,
    volumeTitle: volume.volumeTitle,
    title: metadata.title,
    subtitle: metadata.summary,
    href: metadata.route,
    fields: [
      {
        category: "Lesson ID",
        values: [
          metadata.id,
          metadata.slug,
          ...metadata.aliases,
          ...metadata.curriculumIds,
        ],
        weight: 16,
      },
      {
        category: "Title",
        values: [metadata.title, metadata.summary],
        weight: 14,
      },
      {
        category: "Incident signal",
        values: unique([
          ...metadata.productionSignals,
          ...metadata.incidents.flatMap((incident) => [
            incident.signal,
            incident.firstThought,
            incident.trap,
          ]),
        ]),
        weight: 11,
      },
      {
        category: "Command",
        values: unique(metadata.commands.flatMap((command) => [
          command.command,
          command.question,
        ])),
        weight: 9,
      },
      {
        category: "Term",
        values: unique([
          ...sectionTerms,
          ...metadata.diagrams.flatMap((diagram) => [
            diagram.title,
            ...diagram.boundaries,
            ...diagram.evidencePoints,
          ]),
        ]),
        weight: 8,
      },
      {
        category: "Lesson guidance",
        values: unique([
          metadata.summary,
          ...metadata.learningObjectives,
          ...metadata.incidents.map((incident) => incident.safePath),
          ...metadata.limitations,
        ]),
        weight: 4,
      },
    ],
  };
}
