export type CareerPrimerLibraryItem = Readonly<{ slug: string; title: string }>;

function normalize(value: string): string {
  return value.toLocaleLowerCase("en").replace(/[^a-z0-9]+/g, " ").trim();
}

export function filterCareerPrimerLibrary<T extends CareerPrimerLibraryItem>(
  primers: readonly T[],
  query: string,
): readonly T[] {
  const tokens = normalize(query).split(/\s+/).filter(Boolean).slice(0, 12);
  if (tokens.length === 0) return primers;
  return primers.filter((primer) => {
    const text = normalize(`${primer.title} ${primer.slug}`);
    return tokens.every((token) => text.includes(token));
  });
}
