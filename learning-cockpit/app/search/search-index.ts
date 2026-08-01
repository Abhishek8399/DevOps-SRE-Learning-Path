export const searchCategories = [
  "Lesson ID",
  "Title",
  "Incident signal",
  "Command",
  "Term",
  "Lesson guidance",
] as const;

export type SearchCategory = (typeof searchCategories)[number];

type SearchField = Readonly<{
  category: SearchCategory;
  values: readonly string[];
  weight: number;
}>;

export type SearchDocument = Readonly<{
  id: string;
  number: string;
  title: string;
  subtitle: string;
  href: string;
  fields: readonly SearchField[];
}>;

export type SearchMatch = Readonly<{
  category: SearchCategory;
  value: string;
}>;

export type SearchResult = Readonly<{
  document: SearchDocument;
  matches: readonly SearchMatch[];
  score: number;
}>;

function unique(values: readonly string[]): string[] {
  return [...new Set(values.filter((value) => value.trim().length > 0))];
}

function normalize(value: string): string {
  return value
    .normalize("NFKD")
    .replace(/[\u0300-\u036f]/g, "")
    .toLocaleLowerCase("en")
    .replace(/[^a-z0-9]+/g, " ")
    .trim();
}

function queryTokens(query: string): string[] {
  return unique(normalize(query).split(/\s+/)).slice(0, 12);
}

function bestFieldScore(
  fields: readonly SearchField[],
  token: string,
): number {
  let best = 0;

  for (const field of fields) {
    for (const value of field.values) {
      const normalizedValue = normalize(value);
      if (!normalizedValue.includes(token)) continue;

      const exactBonus = normalizedValue === token ? 8 : 0;
      const wordBonus = normalizedValue.split(" ").includes(token) ? 3 : 0;
      best = Math.max(best, field.weight + exactBonus + wordBonus);
    }
  }

  return best;
}

function matchingExamples(
  fields: readonly SearchField[],
  tokens: readonly string[],
): SearchMatch[] {
  const matches: SearchMatch[] = [];

  for (const field of fields) {
    const value = field.values.find((candidate) => {
      const normalizedValue = normalize(candidate);
      return tokens.some((token) => normalizedValue.includes(token));
    });

    if (value) matches.push({ category: field.category, value });
    if (matches.length === 4) break;
  }

  return matches;
}

export function searchLessons(
  documents: readonly SearchDocument[],
  rawQuery: string,
): SearchResult[] {
  const query = rawQuery.trim().slice(0, 160);
  const tokens = queryTokens(query);
  if (tokens.length === 0) return [];

  const normalizedPhrase = normalize(query);

  const results: SearchResult[] = [];

  for (const document of documents) {
    const tokenScores = tokens.map((token) =>
      bestFieldScore(document.fields, token),
    );
    if (tokenScores.some((score) => score === 0)) continue;

    const title = normalize(document.title);
    const id = normalize(document.id);
    const phraseBonus = title.includes(normalizedPhrase) ? 24 : 0;
    const idBonus = id === normalizedPhrase ? 32 : 0;

    results.push({
        document,
        matches: matchingExamples(document.fields, tokens),
        score: tokenScores.reduce((total, score) => total + score, 0)
          + phraseBonus
          + idBonus,
    });
  }

  return results.sort((left, right) =>
      right.score - left.score
      || left.document.number.localeCompare(right.document.number),
  );
}
