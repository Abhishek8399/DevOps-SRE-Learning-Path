export const LEARNING_LIBRARY_STORAGE_KEY = "field-manual-learning-library-v1";
export const LEARNING_LIBRARY_LESSON_IDS = [
  "storage",
  "processes-signals-systemd",
  "cpu-memory-pressure",
  "network-request-path",
  "identity-permissions",
  "LES-0006",
  "LES-0007",
  "LES-0008",
  "LES-0009",
  "LES-0010",
  "LES-0011",
  "LES-0012",
  "LES-0013",
  "LES-0014",
  "LES-0015",
  "LES-0016",
  "LES-0017",
  "LES-0018",
] as const;

export type LearningLessonId = (typeof LEARNING_LIBRARY_LESSON_IDS)[number];
export type ReadingMarker = "not-started" | "reading" | "finished-reading";

export type LessonConvenienceState = {
  bookmarked: boolean;
  marker: ReadingMarker;
  lastOpenedAt: string | null;
};

export type LearningLibraryState = {
  version: 1;
  recentLessonIds: LearningLessonId[];
  lessons: Record<LearningLessonId, LessonConvenienceState>;
};

export type LearningStateLoadResult = {
  state: LearningLibraryState;
  storageAvailable: boolean;
  recoveredInvalidData: boolean;
};

type StorageLike = Pick<Storage, "getItem" | "setItem">;
type ClearStorageLike = Pick<Storage, "removeItem">;

const defaultLessonState = (): LessonConvenienceState => ({
  bookmarked: false,
  marker: "not-started",
  lastOpenedAt: null,
});

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

export function isLearningLessonId(value: unknown): value is LearningLessonId {
  return (
    typeof value === "string" &&
    LEARNING_LIBRARY_LESSON_IDS.some((lessonId) => lessonId === value)
  );
}

export function isReadingMarker(value: unknown): value is ReadingMarker {
  return value === "not-started" || value === "reading" || value === "finished-reading";
}

function normaliseOpenedAt(value: unknown): string | null {
  if (typeof value !== "string" || value.length > 40 || Number.isNaN(Date.parse(value))) {
    return null;
  }
  return value;
}

export function createEmptyLearningState(): LearningLibraryState {
  return {
    version: 1,
    recentLessonIds: [],
    lessons: Object.fromEntries(
      LEARNING_LIBRARY_LESSON_IDS.map((lessonId) => [lessonId, defaultLessonState()]),
    ) as Record<LearningLessonId, LessonConvenienceState>,
  };
}

export function getLessonConvenienceState(
  state: LearningLibraryState,
  lessonId: LearningLessonId,
): LessonConvenienceState {
  return state.lessons[lessonId];
}

function parseLearningState(raw: string): LearningLibraryState | null {
  let value: unknown;
  try {
    value = JSON.parse(raw);
  } catch {
    return null;
  }

  if (!isRecord(value) || value.version !== 1 || !isRecord(value.lessons)) {
    return null;
  }

  const parsedLessons = {} as Record<LearningLessonId, LessonConvenienceState>;
  for (const lessonId of LEARNING_LIBRARY_LESSON_IDS) {
    const candidate = value.lessons[lessonId];
    if (!isRecord(candidate)) {
      parsedLessons[lessonId] = defaultLessonState();
      continue;
    }
    parsedLessons[lessonId] = {
      bookmarked: candidate.bookmarked === true,
      marker: isReadingMarker(candidate.marker) ? candidate.marker : "not-started",
      lastOpenedAt: normaliseOpenedAt(candidate.lastOpenedAt),
    };
  }

  const recentLessonIds: LearningLessonId[] = [];
  if (Array.isArray(value.recentLessonIds)) {
    for (const candidate of value.recentLessonIds) {
      if (
        isLearningLessonId(candidate) &&
        !recentLessonIds.includes(candidate) &&
        recentLessonIds.length < LEARNING_LIBRARY_LESSON_IDS.length
      ) {
        recentLessonIds.push(candidate);
      }
    }
  }

  return { version: 1, recentLessonIds, lessons: parsedLessons };
}

export function getBrowserLearningStorage(): Storage | null {
  if (typeof window === "undefined") return null;
  try {
    return window.localStorage;
  } catch {
    return null;
  }
}

export function loadLearningState(storage: StorageLike | null): LearningStateLoadResult {
  const emptyState = createEmptyLearningState();
  if (!storage) {
    return { state: emptyState, storageAvailable: false, recoveredInvalidData: false };
  }

  let raw: string | null;
  try {
    raw = storage.getItem(LEARNING_LIBRARY_STORAGE_KEY);
  } catch {
    return { state: emptyState, storageAvailable: false, recoveredInvalidData: false };
  }

  if (raw === null) {
    return { state: emptyState, storageAvailable: true, recoveredInvalidData: false };
  }

  const parsed = parseLearningState(raw);
  return {
    state: parsed ?? emptyState,
    storageAvailable: true,
    recoveredInvalidData: parsed === null,
  };
}

export function saveLearningState(
  storage: StorageLike | null,
  state: LearningLibraryState,
): boolean {
  if (!storage) return false;
  try {
    storage.setItem(LEARNING_LIBRARY_STORAGE_KEY, JSON.stringify(state));
    return true;
  } catch {
    return false;
  }
}

export function clearLearningState(storage: ClearStorageLike | null): boolean {
  if (!storage) return false;
  try {
    storage.removeItem(LEARNING_LIBRARY_STORAGE_KEY);
    return true;
  } catch {
    return false;
  }
}

export function recordLessonOpened(
  state: LearningLibraryState,
  lessonId: LearningLessonId,
  openedAt: string,
): LearningLibraryState {
  const current = getLessonConvenienceState(state, lessonId);
  return {
    ...state,
    recentLessonIds: [lessonId, ...state.recentLessonIds.filter((item) => item !== lessonId)].slice(
      0,
      LEARNING_LIBRARY_LESSON_IDS.length,
    ),
    lessons: {
      ...state.lessons,
      [lessonId]: {
        ...current,
        marker: current.marker === "not-started" ? "reading" : current.marker,
        lastOpenedAt: openedAt,
      },
    },
  };
}

export function setLessonMarker(
  state: LearningLibraryState,
  lessonId: LearningLessonId,
  marker: ReadingMarker,
): LearningLibraryState {
  return {
    ...state,
    lessons: {
      ...state.lessons,
      [lessonId]: { ...getLessonConvenienceState(state, lessonId), marker },
    },
  };
}

export function toggleLessonBookmark(
  state: LearningLibraryState,
  lessonId: LearningLessonId,
): LearningLibraryState {
  const current = getLessonConvenienceState(state, lessonId);
  return {
    ...state,
    lessons: {
      ...state.lessons,
      [lessonId]: { ...current, bookmarked: !current.bookmarked },
    },
  };
}
