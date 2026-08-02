export type ReaderRenderKind = "legacy-storage" | "legacy-foundation" | "structured";

export type ReaderAvailability =
  | "practical-gate"
  | "ready-to-study"
  | "seeded"
  | "substantive-draft"
  | "review-required";

export const READER_VOLUMES = {
  "00-start-safely": {
    volumeId: "00-start-safely",
    volumeNumber: "00",
    volumeTitle: "Start safely",
    volumeRoute: "/book/start",
  },
  "01-linux-systems": {
    volumeId: "01-linux-systems",
    volumeNumber: "01",
    volumeTitle: "Linux systems",
    volumeRoute: "/book/linux",
  },
  "02-connectivity": {
    volumeId: "02-connectivity",
    volumeNumber: "02",
    volumeTitle: "Connectivity",
    volumeRoute: "/book/connectivity",
  },
  "03-engineering-delivery": {
    volumeId: "03-engineering-delivery",
    volumeNumber: "03",
    volumeTitle: "Engineering and delivery",
    volumeRoute: "/book/engineering",
  },
  "04-reliability-operations": {
    volumeId: "04-reliability-operations",
    volumeNumber: "04",
    volumeTitle: "Reliability and operations",
    volumeRoute: "/book/reliability",
  },
} as const;

export type ReaderVolumeId = keyof typeof READER_VOLUMES;
export type ReaderVolumeDescriptor = (typeof READER_VOLUMES)[ReaderVolumeId];

export function getReaderVolume(volumeId: string): ReaderVolumeDescriptor {
  if (!Object.hasOwn(READER_VOLUMES, volumeId)) {
    throw new Error(`reader catalog has unsupported volume: ${volumeId}`);
  }
  return READER_VOLUMES[volumeId as ReaderVolumeId];
}

export type ReaderCatalogEntry = Readonly<{
  canonicalId: string;
  stateId: string;
  slug: string;
  route: string;
  volumeId: ReaderVolumeId;
  volumeNumber: string;
  volumeTitle: string;
  volumeRoute: string;
  order: number;
  number: string;
  title: string;
  summary: string;
  aliases: readonly string[];
  curriculumIds: readonly string[];
  renderKind: ReaderRenderKind;
  availability: ReaderAvailability;
}>;

export type ReaderPrerequisiteContext = Readonly<{
  lessons: readonly ReaderCatalogEntry[];
  curriculumIds: readonly string[];
}>;

export type StructuredReaderMetadata = Readonly<{
  id: string;
  slug: string;
  route: string;
  order: number;
  volume: string;
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
  const volume = getReaderVolume(metadata.volume);
  return {
    canonicalId: metadata.id,
    stateId: metadata.id,
    slug: metadata.slug,
    route: metadata.route,
    ...volume,
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
  ].sort((left, right) => left.volumeNumber.localeCompare(right.volumeNumber)
    || left.order - right.order);

  for (const field of ["canonicalId", "stateId", "slug", "route"] as const) {
    const values = entries.map((entry) => String(entry[field]));
    if (new Set(values).size !== values.length) {
      throw new Error(`reader catalog contains duplicate ${field}`);
    }
  }

  const positions = entries.map((entry) => `${entry.volumeId}:${entry.order}`);
  if (new Set(positions).size !== positions.length) {
    throw new Error("reader catalog contains duplicate volume order");
  }

  for (const entry of entries) {
    if (entry.route !== `${entry.volumeRoute}/${entry.slug}`) {
      throw new Error(`reader route and slug differ for ${entry.canonicalId}`);
    }
  }

  return entries;
}

export function readerEntriesForVolumeInCatalog(
  catalog: readonly ReaderCatalogEntry[],
  volumeId: ReaderVolumeId,
): readonly ReaderCatalogEntry[] {
  return catalog.filter((entry) => entry.volumeId === volumeId);
}

export function findReaderEntryInCatalog(
  catalog: readonly ReaderCatalogEntry[],
  slug: string,
): ReaderCatalogEntry | undefined {
  return catalog.find((entry) => entry.slug === slug);
}

export function findReaderEntryByCanonicalIdInCatalog(
  catalog: readonly ReaderCatalogEntry[],
  canonicalId: string,
): ReaderCatalogEntry | undefined {
  return catalog.find((entry) => entry.canonicalId === canonicalId);
}

export function resolveReaderPrerequisitesInCatalog(
  catalog: readonly ReaderCatalogEntry[],
  prerequisiteLessonIds: readonly string[],
  prerequisiteCurriculumIds: readonly string[],
): ReaderPrerequisiteContext {
  const lessons = prerequisiteLessonIds.map((canonicalId) => {
    const entry = findReaderEntryByCanonicalIdInCatalog(catalog, canonicalId);
    if (!entry) {
      throw new Error(`reader prerequisite ${canonicalId} is missing from the catalog`);
    }
    return entry;
  });

  return {
    lessons,
    curriculumIds: prerequisiteCurriculumIds,
  };
}

export function adjacentReaderEntriesInCatalog(
  catalog: readonly ReaderCatalogEntry[],
  slug: string,
): Readonly<{ previous?: ReaderCatalogEntry; next?: ReaderCatalogEntry }> {
  const current = catalog.find((entry) => entry.slug === slug);
  if (!current) return {};
  const volumeEntries = catalog.filter((entry) => entry.volumeId === current.volumeId);
  const index = volumeEntries.findIndex((entry) => entry.slug === slug);
  if (index < 0) return {};
  return {
    previous: index > 0 ? volumeEntries[index - 1] : undefined,
    next: index < volumeEntries.length - 1 ? volumeEntries[index + 1] : undefined,
  };
}
