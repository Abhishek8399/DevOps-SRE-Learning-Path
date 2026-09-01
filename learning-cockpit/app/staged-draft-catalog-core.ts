export type StagedDraftCatalogItem = Readonly<{
  slug: string;
  lesson: Readonly<{
    metadata: Readonly<{
      volume: string;
      order: number;
    }>;
  }>;
}>;

export function sortStagedDraftCatalog<T extends StagedDraftCatalogItem>(drafts: readonly T[]): readonly T[] {
  return [...drafts].sort((left, right) => left.lesson.metadata.volume.localeCompare(right.lesson.metadata.volume)
    || left.lesson.metadata.order - right.lesson.metadata.order
    || left.slug.localeCompare(right.slug));
}

export function adjacentStagedDraftsInCatalog<T extends StagedDraftCatalogItem>(drafts: readonly T[], slug: string): Readonly<{
  previous: T | undefined;
  next: T | undefined;
}> {
  const catalog = sortStagedDraftCatalog(drafts);
  const index = catalog.findIndex((draft) => draft.slug === slug);
  if (index < 0) return { previous: undefined, next: undefined };
  return { previous: catalog[index - 1], next: catalog[index + 1] };
}
