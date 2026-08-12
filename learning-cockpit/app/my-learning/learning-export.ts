import {
  LEARNING_LIBRARY_LESSON_IDS,
  getLessonConvenienceState,
  type LearningLibraryState,
  type ReadingMarker,
} from "./learning-state.ts";

export type LearningSnapshot = Readonly<{
  kind: "local-reading-snapshot";
  version: 1;
  exportedAt: string;
  lessons: readonly Readonly<{
    lessonId: string;
    bookmarked: boolean;
    marker: ReadingMarker;
  }> [];
  recentLessonIds: readonly string[];
  boundary: string;
}>;

const boundary = "Private browser-local reading convenience snapshot; not a score, reviewed evidence, competency record, hiring signal, or mastery claim.";

export function createLearningSnapshot(state: LearningLibraryState, exportedAt = new Date().toISOString()): LearningSnapshot {
  const lessons = LEARNING_LIBRARY_LESSON_IDS.flatMap((lessonId) => {
    const convenience = getLessonConvenienceState(state, lessonId);
    if (!convenience.bookmarked && convenience.marker === "not-started") return [];
    return [{
      lessonId,
      bookmarked: convenience.bookmarked,
      marker: convenience.marker,
    }];
  });
  return {
    kind: "local-reading-snapshot",
    version: 1,
    exportedAt,
    lessons,
    recentLessonIds: state.recentLessonIds.slice(),
    boundary,
  };
}

export function learningSnapshotAsMarkdown(snapshot: LearningSnapshot): string {
  const rows = snapshot.lessons.length
    ? snapshot.lessons.map((lesson) => `- ${lesson.lessonId}: ${lesson.marker}${lesson.bookmarked ? "; bookmarked" : ""}`)
    : ["- (No bookmarks or reading markers recorded.)"];
  return [
    "# Local reading snapshot",
    "",
    `- Exported: ${snapshot.exportedAt}`,
    `- Boundary: ${snapshot.boundary}`,
    "- Privacy: includes only fixed lesson IDs, bookmark/reading markers, and recent lesson IDs; it excludes notes, responses, commands, credentials, tokens, employer data, and repository writes.",
    "",
    "## Reading markers",
    "",
    ...rows,
    "",
    "## Recently opened lesson IDs",
    "",
    ...(snapshot.recentLessonIds.length ? snapshot.recentLessonIds.map((lessonId) => `- ${lessonId}`) : ["- (None recorded.)"]),
    "",
  ].join("\n");
}

export function learningSnapshotAsJson(snapshot: LearningSnapshot): string {
  return `${JSON.stringify(snapshot, null, 2)}\n`;
}
