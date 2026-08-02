import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import { dirname, join, resolve } from "node:path";
import test from "node:test";
import { fileURLToPath } from "node:url";

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
import { createReaderCatalog } from "../app/lessons/reader-catalog-core.ts";
import {
  REQUIRED_STRUCTURED_SECTIONS,
  isSafeStructuredHref,
  parseMarkdownBlocks,
  parseMarkdownInline,
  parseStructuredAssessment,
  parseStructuredLesson,
  parseStructuredReference,
} from "../app/lessons/structured-lesson-parser.ts";
import { legacySearchDocuments } from "../app/search/legacy-search-catalog.ts";
import { searchLessons } from "../app/search/search-index.ts";
import { createStructuredSearchDocument } from "../app/search/structured-search.ts";

const testDirectory = dirname(fileURLToPath(import.meta.url));
const repositoryRoot = resolve(testDirectory, "..", "..");
const liveLessonPath = join(
  repositoryRoot,
  "book",
  "volumes",
  "01-linux-systems",
  "LES-0006-boot-kernel-systemd-journal",
  "lesson.md",
);
const independentAnswerFields = [
  "directAnswer",
  "foundation",
  "reasoningSteps",
  "seniorAnswer",
  "weakAnswer",
  "whyWeak",
  "evidence",
  "followUps",
];
const expectedLegacyIdentities = [
  ["LES-0001", "storage", "/book/linux/storage"],
  ["LES-0002", "processes-signals-systemd", "/book/linux/processes-signals-systemd"],
  ["LES-0003", "cpu-memory-pressure", "/book/linux/cpu-memory-pressure"],
  ["LES-0004", "network-request-path", "/book/linux/network-request-path"],
  ["LES-0005", "identity-permissions", "/book/linux/identity-permissions"],
];

function readJson(path) {
  return JSON.parse(readFileSync(path, "utf8"));
}

function loadLiveStructuredBundle() {
  const lesson = parseStructuredLesson(readFileSync(liveLessonPath, "utf8"));
  const assessments = lesson.metadata.assessmentIds.map((id) =>
    parseStructuredAssessment(readJson(join(
      repositoryRoot,
      "book",
      "assessments",
      lesson.metadata.domain,
      `${id}.json`,
    ))));
  const references = lesson.metadata.referenceIds.map((id) =>
    parseStructuredReference(readJson(join(
      repositoryRoot,
      "book",
      "references",
      `${id}.json`,
    ))));
  return { lesson, assessments, references };
}

function liveProductionSearchDocuments() {
  const structured = createStructuredSearchDocument(loadLiveStructuredBundle());
  return [
    ...legacySearchDocuments.filter((document) => document.id !== structured.id),
    structured,
  ];
}

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

test("live LES-0006 parses into the exact canonical section contract", () => {
  const { lesson, assessments, references } = loadLiveStructuredBundle();

  assert.equal(lesson.metadata.id, "LES-0006");
  assert.equal(lesson.metadata.slug, "boot-kernel-systemd-journal");
  assert.equal(lesson.metadata.route, "/book/linux/boot-kernel-systemd-journal");
  assert.equal(lesson.metadata.order, 6);
  assert.equal(lesson.metadata.volume, "01-linux-systems");
  assert.deepEqual(lesson.metadata.aliases, ["V01-L06", "boot-kernel-systemd-journal"]);
  assert.deepEqual(lesson.metadata.curriculumIds, ["LNX-005"]);
  assert.deepEqual(
    lesson.sections.map((section) => section.title),
    [...REQUIRED_STRUCTURED_SECTIONS],
  );
  assert.equal(lesson.sections.length, 18);
  assert.equal(new Set(lesson.sections.map((section) => section.anchor)).size, 18);
  assert.ok(lesson.sections.every((section) => section.blocks.length > 0));
  assert.deepEqual(
    assessments.map((assessment) => assessment.id),
    lesson.metadata.assessmentIds,
  );
  assert.deepEqual(
    references.map((reference) => reference.id),
    lesson.metadata.referenceIds,
  );
  assert.ok(assessments.every((assessment) => assessment.lessonId === lesson.metadata.id));
  assert.ok(references.every((reference) => reference.lessonIds.includes(lesson.metadata.id)));
});

test("structured href policy rejects executable, remote-insecure, and malformed destinations", () => {
  for (const href of [
    "#architecture-map",
    "/book/linux/storage",
    "/book/linux/boot-kernel-systemd-journal#decision-path",
    "https://www.freedesktop.org/software/systemd/man/latest/systemd.html",
  ]) assert.equal(isSafeStructuredHref(href), true, `expected safe href: ${href}`);

  for (const href of [
    "javascript:alert(1)",
    "data:text/html,unsafe",
    "http://example.com/insecure",
    "//example.com/protocol-relative",
    "/search",
    "../outside",
    "https://user:password@example.com/private",
    "https://EXAMPLE.com/non-canonical",
  ]) assert.equal(isSafeStructuredHref(href), false, `expected rejected href: ${href}`);

  assert.throws(
    () => parseMarkdownInline("[unsafe](javascript:alert)"),
    /unsafe or malformed structured lesson link/,
  );
});

test("structured Markdown keeps CommonMark tilde and long backtick fences inert", () => {
  const blocks = parseMarkdownBlocks([
    "~~~~bash",
    "printf 'safe\\n'",
    "## not a section",
    "~~~~",
    "",
    "````text",
    "### not a rendered heading",
    "`````",
  ].join("\n"));

  assert.deepEqual(blocks.map((block) => block.kind), ["code", "code"]);
  assert.equal(blocks[0].language, "bash");
  assert.equal(blocks[0].value, "printf 'safe\\n'\n## not a section");
  assert.equal(blocks[1].language, "text");
  assert.equal(blocks[1].value, "### not a rendered heading");

  const liveRaw = readFileSync(liveLessonPath, "utf8");
  const withInertHeading = liveRaw.replace(
    "## What you see and first thought",
    "## What you see and first thought\n\n~~~~text\n## Not a real section\n~~~~",
  );
  assert.notEqual(withInertHeading, liveRaw);
  const parsed = parseStructuredLesson(withInertHeading);
  assert.deepEqual(
    parsed.sections.map((section) => section.title),
    [...REQUIRED_STRUCTURED_SECTIONS],
  );
  assert.equal(parsed.sections[0].blocks[0].kind, "code");
  assert.throws(
    () => parseMarkdownBlocks("~~~text\nunclosed"),
    /unclosed code fence/,
  );
});

test("published legacy route and state identities remain immutable", () => {
  const legacyMap = readJson(join(
    repositoryRoot,
    "book",
    "schema",
    "legacy-content-map.json",
  ));
  assert.deepEqual(
    legacyMap.lessons.map((lesson) => [lesson.id, lesson.slug, lesson.route]),
    expectedLegacyIdentities,
  );
  assert.deepEqual(
    LEARNING_LIBRARY_LESSON_IDS.slice(0, expectedLegacyIdentities.length),
    expectedLegacyIdentities.map(([, stateId]) => stateId),
  );
});

test("the pure combined reader catalog publishes six unique stable identities", () => {
  const legacyMap = readJson(join(
    repositoryRoot,
    "book",
    "schema",
    "legacy-content-map.json",
  ));
  const legacyEntries = legacyMap.lessons.map((lesson, index) => ({
    canonicalId: lesson.id,
    stateId: lesson.slug,
    slug: lesson.slug,
    route: lesson.route,
    order: index + 1,
    number: String(index + 1).padStart(2, "0"),
    title: lesson.slug,
    summary: `Reserved reader identity for ${lesson.id}`,
    aliases: lesson.aliases,
    curriculumIds: lesson.curriculumIds,
    renderKind: index === 0 ? "legacy-storage" : "legacy-foundation",
    availability: index === 0 ? "practical-gate" : "ready-to-study",
  }));
  const structuredMetadata = loadLiveStructuredBundle().lesson.metadata;
  const catalog = createReaderCatalog(legacyEntries, [structuredMetadata]);

  assert.equal(catalog.length, 6);
  assert.deepEqual(
    catalog.map((entry) => [entry.canonicalId, entry.stateId, entry.route]),
    [
      ...expectedLegacyIdentities.map(([id, stateId, route]) => [id, stateId, route]),
      ["LES-0006", "LES-0006", "/book/linux/boot-kernel-systemd-journal"],
    ],
  );
  for (const field of ["canonicalId", "stateId", "slug", "route", "order"]) {
    const values = catalog.map((entry) => String(entry[field]));
    assert.equal(new Set(values).size, 6, `${field} must be unique`);
  }
  assert.equal(catalog[5].renderKind, "structured");
  assert.equal(catalog[5].availability, "substantive-draft");
  assert.throws(
    () => createReaderCatalog(legacyEntries, [{
      ...structuredMetadata,
      route: "/book/linux/storage",
    }]),
    /duplicate route/,
  );
});

test("a five-entry v1 reading state gains an empty LES-0006 record without legacy loss", () => {
  const legacyStateIds = expectedLegacyIdentities.map(([, stateId]) => stateId);
  const legacyLessons = Object.fromEntries(legacyStateIds.map((lessonId, index) => [
    lessonId,
    {
      bookmarked: index % 2 === 0,
      marker: index === 4 ? "finished-reading" : "reading",
      lastOpenedAt: `2026-08-02T00:0${index}:00.000Z`,
    },
  ]));
  const loaded = loadLearningState(new MemoryStorage(JSON.stringify({
    version: 1,
    recentLessonIds: ["identity-permissions", "storage"],
    lessons: legacyLessons,
  })));

  assert.equal(loaded.recoveredInvalidData, false);
  assert.deepEqual(
    [...LEARNING_LIBRARY_LESSON_IDS],
    [...legacyStateIds, "LES-0006"],
  );
  assert.deepEqual(loaded.state.recentLessonIds, ["identity-permissions", "storage"]);
  for (const lessonId of legacyStateIds) {
    assert.deepEqual(loaded.state.lessons[lessonId], legacyLessons[lessonId]);
  }
  assert.deepEqual(loaded.state.lessons["LES-0006"], {
    bookmarked: false,
    marker: "not-started",
    lastOpenedAt: null,
  });
});

test("LES-0006 bookmark and finished-reading state never create mastery data", () => {
  const initial = createEmptyLearningState();
  const bookmarked = toggleLessonBookmark(initial, "LES-0006");
  const finished = setLessonMarker(bookmarked, "LES-0006", "finished-reading");
  const opened = recordLessonOpened(
    finished,
    "LES-0006",
    "2026-08-02T06:00:00.000Z",
  );

  assert.deepEqual(opened.lessons["LES-0006"], {
    bookmarked: true,
    marker: "finished-reading",
    lastOpenedAt: "2026-08-02T06:00:00.000Z",
  });
  assert.equal(opened.recentLessonIds[0], "LES-0006");
  assert.equal(Object.hasOwn(opened.lessons["LES-0006"], "mastery"), false);
  assert.equal(Object.hasOwn(opened, "mastery"), false);
  assert.deepEqual(opened.lessons.storage, initial.lessons.storage);
});

test("the live production search set has six unique lessons and stable golden rankings", () => {
  const documents = liveProductionSearchDocuments();
  assert.deepEqual(
    documents.map((document) => document.id),
    [
      "storage",
      "processes-signals-systemd",
      "cpu-memory-pressure",
      "network-request-path",
      "identity-permissions",
      "LES-0006",
    ],
  );
  assert.equal(new Set(documents.map((document) => document.id)).size, 6);
  assert.equal(new Set(documents.map((document) => document.href)).size, 6);

  const goldenQueries = new Map([
    ["ENOSPC", "storage"],
    ["df -i", "storage"],
    ["SIGTERM", "processes-signals-systemd"],
    ["exit 137", "cpu-memory-pressure"],
    ["curl -v", "network-request-path"],
    ["UID 10001", "identity-permissions"],
    ["journalctl boot", "LES-0006"],
    ["clock skew", "LES-0006"],
    ["systemd-analyze critical-chain", "LES-0006"],
    ["LES-0006", "LES-0006"],
    ["V01-L06", "LES-0006"],
    ["LNX-005", "LES-0006"],
  ]);
  for (const [query, expectedId] of goldenQueries) {
    const results = searchLessons(documents, query);
    assert.equal(results[0]?.document.id, expectedId, `unexpected top result for ${query}`);
  }
});

test("independent transfer stays answer-isolated in the live structured bundle", () => {
  const { assessments } = loadLiveStructuredBundle();
  const independent = assessments.filter((assessment) =>
    assessment.type === "independent-transfer");
  const answered = assessments.filter((assessment) =>
    assessment.type !== "independent-transfer");

  assert.equal(independent.length, 1);
  assert.equal(answered.length, 2);
  assert.equal(independent[0].id, "ASM-0003");
  assert.equal(independent[0].reviewPolicy, "reviewer-only-no-model-answer");
  assert.ok(independent[0].deliverables.length > 0);
  assert.ok(independent[0].evidenceRequirements.length > 0);
  for (const field of independentAnswerFields) {
    assert.equal(Object.hasOwn(independent[0], field), false, `answer field leaked: ${field}`);
  }
  for (const assessment of answered) {
    for (const field of independentAnswerFields) {
      assert.equal(Object.hasOwn(assessment, field), true, `answered field missing: ${field}`);
    }
  }
});
