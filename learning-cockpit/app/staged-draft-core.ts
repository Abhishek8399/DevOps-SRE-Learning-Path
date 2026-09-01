import { parseStructuredLesson } from "./lessons/structured-lesson-parser.ts";

export type StagedDraft = Readonly<{
  slug: string;
  lesson: ReturnType<typeof parseStructuredLesson>;
}>;

export function parseStagedDraft(source: Readonly<{ slug: string; source: string }>): StagedDraft {
  try {
    return { slug: source.slug, lesson: parseStructuredLesson(source.source) };
  } catch (error) {
    const detail = error instanceof Error ? error.message : String(error);
    throw new Error(`staged draft ${source.slug} cannot render: ${detail}`, { cause: error });
  }
}
