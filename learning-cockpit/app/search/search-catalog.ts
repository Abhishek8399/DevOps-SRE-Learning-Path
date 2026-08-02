import { structuredLessonBundles } from "../lessons/structured-lessons.server";
import type { SearchDocument } from "./search-index";
import { legacySearchDocuments } from "./legacy-search-catalog";
import { createStructuredSearchDocument } from "./structured-search";

export const searchDocuments: readonly SearchDocument[] = [
  ...legacySearchDocuments,
  ...structuredLessonBundles.map(createStructuredSearchDocument),
];
