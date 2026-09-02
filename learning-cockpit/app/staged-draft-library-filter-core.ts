export type StagedDraftFilterItem = Readonly<{
  slug: string;
  id: string;
  title: string;
  searchValues: readonly string[];
}>;

function normalize(value: string): string {
  return value
    .normalize("NFKD")
    .replace(/[\u0300-\u036f]/g, "")
    .toLocaleLowerCase("en")
    .replace(/[^a-z0-9]+/g, " ")
    .trim();
}

export function filterStagedDraftLibrary<T extends StagedDraftFilterItem>(
  drafts: readonly T[],
  query: string,
): readonly T[] {
  const tokens = [...new Set(normalize(query).split(/\s+/).filter(Boolean))].slice(0, 12);
  if (tokens.length === 0) return drafts;

  return drafts.filter((draft) => {
    const searchableText = normalize([draft.id, draft.slug, draft.title, ...draft.searchValues].join(" "));
    return tokens.every((token) => searchableText.includes(token));
  });
}
