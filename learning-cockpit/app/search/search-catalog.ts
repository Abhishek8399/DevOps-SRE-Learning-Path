import { generatedCareerPrimerSources } from "virtual:career-primers";
import { structuredLessonBundles } from "../lessons/structured-lessons.server";
import { findReaderEntryByCanonicalId } from "../lessons/reader-catalog";
import type { SearchDocument } from "./search-index";
import { createCareerPrimerSearchDocuments } from "./career-search";
import { legacySearchDocuments } from "./legacy-search-catalog";
import { createStructuredSearchDocument } from "./structured-search";
import { navigationSearchDocuments } from "./navigation-search-documents";
import { createStagedDraftSearchDocuments } from "./staged-draft-search";
import { stagedDrafts } from "../staged-draft.server";

const structuredSearchDocuments = structuredLessonBundles.map((bundle) =>
  createStructuredSearchDocument(
    bundle,
    findReaderEntryByCanonicalId(bundle.lesson.metadata.id)?.stateId,
  ));
const structuredByRoute = new Map(
  structuredSearchDocuments.map((document) => [document.href, document]),
);
const legacyRoutes = new Set(legacySearchDocuments.map((document) => document.href));
const lessonSearchDocuments = [
  ...legacySearchDocuments.map((document) =>
    structuredByRoute.get(document.href) ?? document),
  ...structuredSearchDocuments.filter((document) => !legacyRoutes.has(document.href)),
];

export const searchDocuments: readonly SearchDocument[] = [
  ...navigationSearchDocuments,
  ...lessonSearchDocuments,
  ...createCareerPrimerSearchDocuments(generatedCareerPrimerSources),
  ...createStagedDraftSearchDocuments(stagedDrafts),
];
