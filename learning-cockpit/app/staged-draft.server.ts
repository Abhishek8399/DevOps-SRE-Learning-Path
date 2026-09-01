import { generatedStagedDraftSources } from "virtual:staged-drafts";
import { parseStructuredLesson } from "./lessons/structured-lesson-parser";

export type StagedDraft = Readonly<{
  slug: string;
  lesson: ReturnType<typeof parseStructuredLesson>;
}>;

export const stagedDrafts: readonly StagedDraft[] = generatedStagedDraftSources.map((draft) => ({
  slug: draft.slug,
  lesson: parseStructuredLesson(draft.source),
}));

export function findStagedDraft(slug: string): StagedDraft | undefined {
  return stagedDrafts.find((draft) => draft.slug === slug);
}
