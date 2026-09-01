import { generatedStagedDraftSources } from "virtual:staged-drafts";
import { parseStagedDraft, type StagedDraft } from "./staged-draft-core";

export type { StagedDraft } from "./staged-draft-core";

export const stagedDrafts: readonly StagedDraft[] = generatedStagedDraftSources.map(parseStagedDraft);

export function findStagedDraft(slug: string): StagedDraft | undefined {
  return stagedDrafts.find((draft) => draft.slug === slug);
}
