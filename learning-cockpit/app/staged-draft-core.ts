import { parseStructuredAssessment, parseStructuredLesson, type StructuredAssessment } from "./lessons/structured-lesson-parser.ts";

export type StagedDraft = Readonly<{
  slug: string;
  lesson: ReturnType<typeof parseStructuredLesson>;
  assessments: readonly StructuredAssessment[];
}>;

export function parseStagedDraft(source: Readonly<{ slug: string; source: string; assessments: readonly unknown[] }>): StagedDraft {
  try {
    const lesson = parseStructuredLesson(source.source);
    const assessments = source.assessments.map(parseStructuredAssessment);
    if (assessments.length !== 3 || assessments.some((assessment) => assessment.lessonId !== lesson.metadata.id)) {
      throw new Error("assessment records do not match the lesson contract");
    }
    return { slug: source.slug, lesson, assessments };
  } catch (error) {
    const detail = error instanceof Error ? error.message : String(error);
    throw new Error(`staged draft ${source.slug} cannot render: ${detail}`, { cause: error });
  }
}
