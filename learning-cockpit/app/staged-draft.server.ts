import { generatedStagedDraftSources } from "virtual:staged-drafts";
import { adjacentStagedDraftsInCatalog, sortStagedDraftCatalog } from "./staged-draft-catalog-core";
import { parseStagedDraft, type StagedDraft } from "./staged-draft-core";

export type { StagedDraft } from "./staged-draft-core";

export const stagedDrafts: readonly StagedDraft[] = sortStagedDraftCatalog(generatedStagedDraftSources.map(parseStagedDraft));

export function findStagedDraft(slug: string): StagedDraft | undefined {
  return stagedDrafts.find((draft) => draft.slug === slug);
}

export function adjacentStagedDrafts(slug: string) {
  return adjacentStagedDraftsInCatalog(stagedDrafts, slug);
}
