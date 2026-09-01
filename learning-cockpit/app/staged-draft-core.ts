import { parseStructuredAssessment, parseStructuredLesson, parseStructuredReference, type StructuredAssessment, type StructuredReference } from "./lessons/structured-lesson-parser.ts";

export type StagedDraft = Readonly<{
  slug: string;
  lesson: ReturnType<typeof parseStructuredLesson>;
  assessments: readonly StructuredAssessment[];
  references: readonly StructuredReference[];
}>;

export function parseStagedDraft(source: Readonly<{ slug: string; source: string; assessments: readonly unknown[]; references: readonly unknown[] }>): StagedDraft {
  try {
    const lesson = parseStructuredLesson(source.source);
    const assessments = source.assessments.map(parseStructuredAssessment);
    const references = source.references.map(parseStructuredReference);
    if (assessments.length !== 3 || assessments.some((assessment) => assessment.lessonId !== lesson.metadata.id)) {
      throw new Error("assessment records do not match the lesson contract");
    }
    if (references.length !== lesson.metadata.referenceIds.length
      || references.some((reference, index) => reference.id !== lesson.metadata.referenceIds[index])) {
      throw new Error("reference records do not match the lesson contract");
    }
    return { slug: source.slug, lesson, assessments, references };
  } catch (error) {
    const detail = error instanceof Error ? error.message : String(error);
    throw new Error(`staged draft ${source.slug} cannot render: ${detail}`, { cause: error });
  }
}
