export type ReaderRenderKind = "legacy-storage" | "legacy-foundation" | "structured";

export type ReaderAvailability =
  | "practical-gate"
  | "ready-to-study"
  | "seeded"
  | "substantive-draft"
  | "review-required";

export type ReaderCatalogEntry = Readonly<{
  canonicalId: string;
  stateId: string;
  slug: string;
  route: string;
  order: number;
  number: string;
  title: string;
  summary: string;
  aliases: readonly string[];
  curriculumIds: readonly string[];
  renderKind: ReaderRenderKind;
  availability: ReaderAvailability;
}>;

export type StructuredReaderMetadata = Readonly<{
  id: string;
  slug: string;
  route: string;
  order: number;
  title: string;
  summary: string;
  aliases: readonly string[];
  curriculumIds: readonly string[];
  contentStatus: string;
}>;

function structuredAvailability(value: string): ReaderAvailability {
  if (
    value === "seeded"
    || value === "substantive-draft"
    || value === "review-required"
  ) {
    return value;
  }
  throw new Error(`structured lesson has unsupported content status: ${value}`);
}

export function createStructuredReaderEntry(
  metadata: StructuredReaderMetadata,
): ReaderCatalogEntry {
  return {
    canonicalId: metadata.id,
    stateId: metadata.id,
    slug: metadata.slug,
    route: metadata.route,
    order: metadata.order,
    number: String(metadata.order).padStart(2, "0"),
    title: metadata.title,
    summary: metadata.summary,
    aliases: metadata.aliases,
    curriculumIds: metadata.curriculumIds,
    renderKind: "structured",
    availability: structuredAvailability(metadata.contentStatus),
  };
}

export function createReaderCatalog(
  legacyEntries: readonly ReaderCatalogEntry[],
  structuredLessons: readonly StructuredReaderMetadata[],
): readonly ReaderCatalogEntry[] {
  const entries = [
    ...legacyEntries,
    ...structuredLessons.map(createStructuredReaderEntry),
  ].sort((left, right) => left.order - right.order);

  for (const field of ["canonicalId", "stateId", "slug", "route", "order"] as const) {
    const values = entries.map((entry) => String(entry[field]));
    if (new Set(values).size !== values.length) {
      throw new Error(`reader catalog contains duplicate ${field}`);
    }
  }

  for (const entry of entries) {
    if (entry.route !== `/book/linux/${entry.slug}`) {
      throw new Error(`reader route and slug differ for ${entry.canonicalId}`);
    }
  }

  return entries;
}

export function findReaderEntryInCatalog(
  catalog: readonly ReaderCatalogEntry[],
  slug: string,
): ReaderCatalogEntry | undefined {
  return catalog.find((entry) => entry.slug === slug);
}

export function adjacentReaderEntriesInCatalog(
  catalog: readonly ReaderCatalogEntry[],
  slug: string,
): Readonly<{ previous?: ReaderCatalogEntry; next?: ReaderCatalogEntry }> {
  const index = catalog.findIndex((entry) => entry.slug === slug);
  if (index < 0) return {};
  return {
    previous: index > 0 ? catalog[index - 1] : undefined,
    next: index < catalog.length - 1 ? catalog[index + 1] : undefined,
  };
}
