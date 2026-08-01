import assert from "node:assert/strict";
import test from "node:test";

import {
  LEARNING_LIBRARY_LESSON_IDS,
  LEARNING_LIBRARY_STORAGE_KEY,
  clearLearningState,
  createEmptyLearningState,
  loadLearningState,
  recordLessonOpened,
  saveLearningState,
  setLessonMarker,
  toggleLessonBookmark,
} from "../app/my-learning/learning-state.ts";
import { searchLessons } from "../app/search/search-index.ts";

class MemoryStorage {
  constructor(initial = null) {
    this.value = initial;
  }

  getItem(key) {
    assert.equal(key, LEARNING_LIBRARY_STORAGE_KEY);
    return this.value;
  }

  setItem(key, value) {
    assert.equal(key, LEARNING_LIBRARY_STORAGE_KEY);
    this.value = value;
  }

  removeItem(key) {
    assert.equal(key, LEARNING_LIBRARY_STORAGE_KEY);
    this.value = null;
  }
}

test("malformed and unsupported saved state recover to a safe empty schema", () => {
  for (const raw of ["{", JSON.stringify({ version: 2, lessons: {} })]) {
    const loaded = loadLearningState(new MemoryStorage(raw));
    assert.equal(loaded.storageAvailable, true);
    assert.equal(loaded.recoveredInvalidData, true);
    assert.deepEqual(loaded.state.recentLessonIds, []);
    assert.deepEqual(Object.keys(loaded.state.lessons), [...LEARNING_LIBRARY_LESSON_IDS]);
  }
});

test("unknown IDs, duplicate recents, invalid markers, and invalid timestamps are discarded", () => {
  const raw = JSON.stringify({
    version: 1,
    recentLessonIds: ["unknown-route", "storage", "storage"],
    lessons: {
      storage: {
        bookmarked: "yes",
        marker: "mastered",
        lastOpenedAt: "not-a-time",
        href: "https://attacker.invalid/",
      },
      "unknown-route": {
        bookmarked: true,
        marker: "finished-reading",
        lastOpenedAt: "2026-08-02T00:00:00.000Z",
      },
    },
  });
  const loaded = loadLearningState(new MemoryStorage(raw));

  assert.equal(loaded.recoveredInvalidData, false);
  assert.deepEqual(loaded.state.recentLessonIds, ["storage"]);
  assert.deepEqual(loaded.state.lessons.storage, {
    bookmarked: false,
    marker: "not-started",
    lastOpenedAt: null,
  });
  assert.equal(Object.hasOwn(loaded.state.lessons, "unknown-route"), false);
});

test("storage read and write failures fall back without throwing", () => {
  const throwingRead = {
    getItem() {
      throw new Error("blocked");
    },
    setItem() {},
  };
  const throwingWrite = {
    getItem() {
      return null;
    },
    setItem() {
      throw new Error("quota");
    },
  };

  assert.equal(loadLearningState(throwingRead).storageAvailable, false);
  assert.equal(saveLearningState(throwingWrite, createEmptyLearningState()), false);
});

test("clearing removes persisted markers and reports refusal without throwing", () => {
  const storage = new MemoryStorage(JSON.stringify({ version: 1, lessons: {} }));
  assert.equal(clearLearningState(storage), true);
  assert.equal(storage.value, null);

  const throwingClear = {
    removeItem() {
      throw new Error("blocked");
    },
  };
  assert.equal(clearLearningState(throwingClear), false);
  assert.equal(clearLearningState(null), false);
});

test("bookmark and reading transitions preserve unrelated lessons", () => {
  const empty = createEmptyLearningState();
  const bookmarked = toggleLessonBookmark(empty, "storage");
  const finished = setLessonMarker(bookmarked, "storage", "finished-reading");
  const openedAgain = recordLessonOpened(
    finished,
    "storage",
    "2026-08-02T00:00:00.000Z",
  );

  assert.equal(openedAgain.lessons.storage.bookmarked, true);
  assert.equal(openedAgain.lessons.storage.marker, "finished-reading");
  assert.equal(openedAgain.lessons["processes-signals-systemd"].marker, "not-started");
});

test("recent history is ordered, duplicate-free, and capped to the trusted catalog", () => {
  let state = createEmptyLearningState();
  for (const [index, lessonId] of LEARNING_LIBRARY_LESSON_IDS.entries()) {
    state = recordLessonOpened(state, lessonId, `2026-08-02T00:0${index}:00.000Z`);
  }
  state = recordLessonOpened(state, "storage", "2026-08-02T00:10:00.000Z");

  assert.equal(state.recentLessonIds.length, LEARNING_LIBRARY_LESSON_IDS.length);
  assert.equal(state.recentLessonIds[0], "storage");
  assert.equal(new Set(state.recentLessonIds).size, state.recentLessonIds.length);
});

const searchFixture = [
  {
    id: "storage",
    number: "01",
    title: "Storage and ENOSPC",
    subtitle: "Blocks and inodes",
    href: "/book/linux/storage",
    fields: [
      { category: "Lesson ID", values: ["storage", "LNX-001"], weight: 16 },
      { category: "Command", values: ["df -i /path"], weight: 9 },
      { category: "Incident signal", values: ["No space left on device"], weight: 11 },
    ],
  },
  {
    id: "cpu-memory-pressure",
    number: "03",
    title: "CPU and memory pressure",
    subtitle: "OOM evidence",
    href: "/book/linux/cpu-memory-pressure",
    fields: [
      { category: "Lesson ID", values: ["LNX-003"], weight: 16 },
      { category: "Incident signal", values: ["Container exit 137 after SIGKILL"], weight: 11 },
    ],
  },
  {
    id: "identity-permissions",
    number: "05",
    title: "Identity and permissions",
    subtitle: "Path traversal",
    href: "/book/linux/identity-permissions",
    fields: [
      { category: "Incident signal", values: ["Permission denied"], weight: 11 },
    ],
  },
  {
    id: "storage-overview",
    number: "99",
    title: "Storage overview",
    subtitle: "Index page",
    href: "/book/storage-overview",
    fields: [{ category: "Title", values: ["Storage overview"], weight: 14 }],
  },
];

test("search normalizes case, whitespace, punctuation, and command tokens", () => {
  assert.equal(searchLessons(searchFixture, "  DF   -i ")[0].document.id, "storage");
  assert.equal(searchLessons(searchFixture, "EXIT 137")[0].document.id, "cpu-memory-pressure");
  assert.equal(searchLessons(searchFixture, "permission-denied")[0].document.id, "identity-permissions");
  assert.deepEqual(searchLessons(searchFixture, "definitely absent"), []);
});

test("exact stable lesson ID outranks a title-only match", () => {
  const results = searchLessons(searchFixture, "storage");
  assert.equal(results[0].document.id, "storage");
  assert.ok(results.every((result) => result.document.href.startsWith("/")));
});
