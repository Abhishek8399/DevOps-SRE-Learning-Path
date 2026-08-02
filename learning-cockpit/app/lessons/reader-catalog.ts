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

function legacyRecord(id: string): LegacyRecord {
  const record = legacyRecords.find((candidate) => candidate.id === id);
  if (!record) throw new Error(`legacy reader identity is missing: ${id}`);
  return record;
}

function numberFromAlias(aliases: readonly string[]): number {
  const publicAlias = aliases.find((alias) => /^V\d{2}-L\d{2,3}$/.test(alias));
  if (!publicAlias) throw new Error("reader entry has no public V##-L## alias");
  return Number(publicAlias.split("-L")[1]);
}

const storageIdentity = legacyRecord("LES-0001");
const linuxVolume = getReaderVolume("01-linux-systems");
const legacyEntries: ReaderCatalogEntry[] = [
  {
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
  },
  ...foundationLessons.map((lesson): ReaderCatalogEntry => {
    const identity = legacyRecords.find((candidate) => candidate.slug === lesson.id);
    if (!identity) throw new Error(`legacy reader identity is missing: ${lesson.id}`);
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

if (legacyEntries.length !== legacyRecords.length) {
  throw new Error("reader catalog does not publish every reserved legacy lesson");
}

export const readerCatalog = createReaderCatalog(
  legacyEntries,
  structuredLessonBundles.map((bundle) => bundle.lesson.metadata),
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
