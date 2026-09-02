import legacyContentMapValue from "../../../book/schema/legacy-content-map.json";
import { foundationLessons } from "./foundation-lessons";
import {
  adjacentReaderEntriesInCatalog,
  createReaderCatalog,
  findReaderEntryByCanonicalIdInCatalog,
  findReaderEntryInCatalog,
  getReaderVolume,
  readerEntriesForVolumeInCatalog,
  resolveReaderPrerequisitesInCatalog,
  type ReaderCatalogEntry,
  type ReaderPrerequisiteContext,
  type ReaderVolumeId,
} from "./reader-catalog-core";
import { structuredLessonBundles } from "./structured-lessons.server";

export type {
  ReaderCatalogEntry,
  ReaderPrerequisiteContext,
  ReaderRenderKind,
  ReaderVolumeId,
} from "./reader-catalog-core";

type LegacyRecord = Readonly<{
  id: string;
  aliases: readonly string[];
  curriculumIds: readonly string[];
  slug: string;
  route: string;
}>;

const legacyRecords = (legacyContentMapValue as { lessons: LegacyRecord[] }).lessons;
const structuredLessonIds = new Set(
  structuredLessonBundles.map((bundle) => bundle.lesson.metadata.id),
);
const unmigratedLegacyRecords = legacyRecords.filter(
  (record) => !structuredLessonIds.has(record.id),
);
const migratedLegacyStateIds = Object.fromEntries(
  legacyRecords
    .filter((record) => structuredLessonIds.has(record.id))
    .map((record) => [record.id, record.slug]),
);

function legacyRecord(id: string): LegacyRecord {
  const record = legacyRecords.find((candidate) => candidate.id === id);
  if (!record) throw new Error(`legacy reader identity is missing: ${id}`);
  return record;
}

function legacyRecordBySlug(slug: string): LegacyRecord {
  const record = legacyRecords.find((candidate) => candidate.slug === slug);
  if (!record) throw new Error(`legacy reader identity is missing: ${slug}`);
  return record;
}

function numberFromAlias(aliases: readonly string[]): number {
  const publicAlias = aliases.find((alias) => /^V\d{2}-L\d{2,3}$/.test(alias));
  if (!publicAlias) throw new Error("reader entry has no public V##-L## alias");
  return Number(publicAlias.split("-L")[1]);
}

const linuxVolume = getReaderVolume("01-linux-systems");
const storageIdentity = legacyRecord("LES-0001");
const legacyEntries: ReaderCatalogEntry[] = [
  ...(structuredLessonIds.has(storageIdentity.id) ? [] : [{
    canonicalId: storageIdentity.id,
    stateId: storageIdentity.slug,
    slug: storageIdentity.slug,
    route: storageIdentity.route,
    ...linuxVolume,
    order: numberFromAlias(storageIdentity.aliases),
    number: String(numberFromAlias(storageIdentity.aliases)).padStart(2, "0"),
    title: "Filesystems, blocks, inodes, and ENOSPC",
    summary: "Map the exact path, distinguish capacity from inode exhaustion, and recover without blind deletion.",
    aliases: storageIdentity.aliases,
    curriculumIds: storageIdentity.curriculumIds,
    renderKind: "legacy-storage",
    availability: "practical-gate",
  } satisfies ReaderCatalogEntry]),
  ...foundationLessons
    .filter((lesson) => !structuredLessonIds.has(legacyRecordBySlug(lesson.id).id))
    .map((lesson): ReaderCatalogEntry => {
    const identity = legacyRecordBySlug(lesson.id);
    return {
      canonicalId: identity.id,
      stateId: identity.slug,
      slug: identity.slug,
      route: identity.route,
      ...linuxVolume,
      order: numberFromAlias(identity.aliases),
      number: lesson.number,
      title: lesson.title,
      summary: lesson.subtitle,
      aliases: identity.aliases,
      curriculumIds: identity.curriculumIds,
      renderKind: "legacy-foundation",
      availability: "ready-to-study",
    };
  }),
];

if (legacyEntries.length !== unmigratedLegacyRecords.length) {
  throw new Error("reader catalog does not publish every unmigrated legacy lesson");
}

export const readerCatalog = createReaderCatalog(
  legacyEntries,
  structuredLessonBundles.map((bundle) => bundle.lesson.metadata),
  migratedLegacyStateIds,
);

export function findReaderEntry(slug: string): ReaderCatalogEntry | undefined {
  return findReaderEntryInCatalog(readerCatalog, slug);
}

export function findReaderEntryByCanonicalId(
  canonicalId: string,
): ReaderCatalogEntry | undefined {
  return findReaderEntryByCanonicalIdInCatalog(readerCatalog, canonicalId);
}

export function resolveReaderPrerequisites(
  prerequisiteLessonIds: readonly string[],
  prerequisiteCurriculumIds: readonly string[],
): ReaderPrerequisiteContext {
  return resolveReaderPrerequisitesInCatalog(
    readerCatalog,
    prerequisiteLessonIds,
    prerequisiteCurriculumIds,
  );
}

export function readerEntriesForVolume(
  volumeId: ReaderVolumeId,
): readonly ReaderCatalogEntry[] {
  return readerEntriesForVolumeInCatalog(readerCatalog, volumeId);
}

export function adjacentReaderEntries(slug: string): Readonly<{
  previous?: ReaderCatalogEntry;
  next?: ReaderCatalogEntry;
}> {
  return adjacentReaderEntriesInCatalog(readerCatalog, slug);
}
