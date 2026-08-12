import { generatedCareerPrimerSources } from "virtual:career-primers";
import { structuredLessonBundles } from "../lessons/structured-lessons.server";
import type { SearchDocument } from "./search-index";
import { createCareerPrimerSearchDocuments } from "./career-search";
import { legacySearchDocuments } from "./legacy-search-catalog";
import { createStructuredSearchDocument } from "./structured-search";
import { navigationSearchDocuments } from "./navigation-search-documents";

export const searchDocuments: readonly SearchDocument[] = [
  ...navigationSearchDocuments,
  ...legacySearchDocuments,
  ...structuredLessonBundles.map(createStructuredSearchDocument),
  ...createCareerPrimerSearchDocuments(generatedCareerPrimerSources),
];
