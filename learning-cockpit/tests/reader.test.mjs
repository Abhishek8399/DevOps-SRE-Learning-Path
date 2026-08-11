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
import {
  adjacentReaderEntriesInCatalog,
  createReaderCatalog,
  findReaderEntryByCanonicalIdInCatalog,
  getReaderVolume,
  resolveReaderPrerequisitesInCatalog,
} from "../app/lessons/reader-catalog-core.ts";
import { bookContent } from "../build/book-content-vite-plugin.ts";
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
import { navigationSearchDocuments } from "../app/search/navigation-search-documents.ts";
import { createStructuredSearchDocument } from "../app/search/structured-search.ts";

const testDirectory = dirname(fileURLToPath(import.meta.url));
const repositoryRoot = resolve(testDirectory, "..", "..");
const liveLessonDescriptors = [
  {
    id: "LES-0007",
    path: join(
      repositoryRoot,
      "book",
      "volumes",
      "00-start-safely",
      "LES-0007-systems-thinking",
      "lesson.md",
    ),
    expected: {
      aliases: ["V00-L01", "systems-thinking"],
      curriculumIds: ["FND-001"],
      prerequisiteCurriculumIds: [],
      prerequisiteLessonIds: [],
      order: 1,
      route: "/book/start/systems-thinking",
      slug: "systems-thinking",
      volume: "00-start-safely",
    },
  },
  {
    id: "LES-0008",
    path: join(
      repositoryRoot,
      "book",
      "volumes",
      "00-start-safely",
      "LES-0008-evidence-driven-troubleshooting",
      "lesson.md",
    ),
    expected: {
      aliases: ["V00-L02", "evidence-driven-troubleshooting"],
      curriculumIds: ["DBG-001"],
      prerequisiteCurriculumIds: ["FND-001"],
      prerequisiteLessonIds: ["LES-0007"],
      order: 2,
      route: "/book/start/evidence-driven-troubleshooting",
      slug: "evidence-driven-troubleshooting",
      volume: "00-start-safely",
    },
  },
  {
    id: "LES-0009",
    path: join(
      repositoryRoot,
      "book",
      "volumes",
      "03-engineering-delivery",
      "LES-0009-safe-local-workbench",
      "lesson.md",
    ),
    expected: {
      aliases: ["V03-L01", "safe-local-workbench"],
      curriculumIds: ["SCM-001"],
      prerequisiteCurriculumIds: ["FND-001"],
      prerequisiteLessonIds: ["LES-0007", "LES-0008"],
      order: 1,
      route: "/book/engineering/safe-local-workbench",
      slug: "safe-local-workbench",
      volume: "03-engineering-delivery",
    },
  },
  {
    id: "LES-0006",
    path: join(
      repositoryRoot,
      "book",
      "volumes",
      "01-linux-systems",
      "LES-0006-boot-kernel-systemd-journal",
      "lesson.md",
    ),
    expected: {
      aliases: ["V01-L06", "boot-kernel-systemd-journal"],
      curriculumIds: ["LNX-005"],
      prerequisiteCurriculumIds: ["LNX-002"],
      prerequisiteLessonIds: ["LES-0002"],
      order: 6,
      route: "/book/linux/boot-kernel-systemd-journal",
      slug: "boot-kernel-systemd-journal",
      volume: "01-linux-systems",
    },
  },
  {
    id: "LES-0010",
    path: join(
      repositoryRoot,
      "book",
      "volumes",
      "01-linux-systems",
      "LES-0010-block-io-storage-performance",
      "lesson.md",
    ),
    expected: {
      aliases: ["V01-L07", "block-io-storage-performance"],
      curriculumIds: ["LNX-006"],
      prerequisiteCurriculumIds: ["LNX-001", "LNX-003"],
      prerequisiteLessonIds: ["LES-0001", "LES-0003"],
      order: 7,
      route: "/book/linux/block-io-storage-performance",
      slug: "block-io-storage-performance",
      volume: "01-linux-systems",
    },
  },
  {
    id: "LES-0011",
    path: join(
      repositoryRoot,
      "book",
      "volumes",
      "01-linux-systems",
      "LES-0011-namespaces-cgroups-isolation",
      "lesson.md",
    ),
    expected: {
      aliases: ["V01-L08", "namespaces-cgroups-isolation"],
      curriculumIds: ["LNX-007"],
      prerequisiteCurriculumIds: ["LNX-002", "LNX-003", "LNX-004", "NET-003"],
      prerequisiteLessonIds: ["LES-0002", "LES-0003", "LES-0004", "LES-0005"],
      order: 8,
      route: "/book/linux/namespaces-cgroups-isolation",
      slug: "namespaces-cgroups-isolation",
      volume: "01-linux-systems",
    },
  },
  {
    id: "LES-0012",
    path: join(
      repositoryRoot,
      "book",
      "volumes",
      "02-connectivity",
      "LES-0012-ethernet-ip-cidr-routing-nat",
      "lesson.md",
    ),
    expected: {
      aliases: ["V02-L01", "ethernet-ip-cidr-routing-nat"],
      curriculumIds: ["NET-001", "NET-002"],
      prerequisiteCurriculumIds: ["FND-001"],
      prerequisiteLessonIds: ["LES-0007"],
      order: 1,
      route: "/book/connectivity/ethernet-ip-cidr-routing-nat",
      slug: "ethernet-ip-cidr-routing-nat",
      volume: "02-connectivity",
    },
  },
  {
    id: "LES-0013",
    path: join(
      repositoryRoot,
      "book",
      "volumes",
      "02-connectivity",
      "LES-0013-tcp-udp-sockets-exhaustion",
      "lesson.md",
    ),
    expected: {
      aliases: ["V02-L02", "tcp-udp-sockets-exhaustion"],
      curriculumIds: ["NET-007"],
      prerequisiteCurriculumIds: ["NET-001", "NET-002", "NET-003", "NET-004", "NET-005", "NET-006"],
      prerequisiteLessonIds: ["LES-0012", "LES-0004"],
      order: 2,
      route: "/book/connectivity/tcp-udp-sockets-exhaustion",
      slug: "tcp-udp-sockets-exhaustion",
      volume: "02-connectivity",
    },
  },
  {
    id: "LES-0014",
    path: join(
      repositoryRoot,
      "book",
      "volumes",
      "02-connectivity",
      "LES-0014-dns-service-discovery",
      "lesson.md",
    ),
    expected: {
      aliases: ["V02-L03", "dns-service-discovery"],
      curriculumIds: ["NET-004"],
      prerequisiteCurriculumIds: ["NET-001", "NET-002", "NET-003"],
      prerequisiteLessonIds: ["LES-0012", "LES-0013"],
      order: 3,
      route: "/book/connectivity/dns-service-discovery",
      slug: "dns-service-discovery",
      volume: "02-connectivity",
    },
  },
  {
    id: "LES-0015",
    path: join(
      repositoryRoot,
      "book",
      "volumes",
      "02-connectivity",
      "LES-0015-http-proxies-load-balancing",
      "lesson.md",
    ),
    expected: {
      aliases: ["V02-L04", "http-proxies-load-balancing"],
      curriculumIds: ["NET-005"],
      prerequisiteCurriculumIds: ["NET-003", "NET-004"],
      prerequisiteLessonIds: ["LES-0013", "LES-0014"],
      order: 4,
      route: "/book/connectivity/http-proxies-load-balancing",
      slug: "http-proxies-load-balancing",
      volume: "02-connectivity",
    },
  },
  {
    id: "LES-0016",
    path: join(
      repositoryRoot,
      "book",
      "volumes",
      "02-connectivity",
      "LES-0016-tls-pki-mtls-rotation",
      "lesson.md",
    ),
    expected: {
      aliases: ["V02-L05", "tls-pki-mtls-rotation"],
      curriculumIds: ["NET-006"],
      prerequisiteCurriculumIds: ["NET-004", "NET-005"],
      prerequisiteLessonIds: ["LES-0014", "LES-0015"],
      order: 5,
      route: "/book/connectivity/tls-pki-mtls-rotation",
      slug: "tls-pki-mtls-rotation",
      volume: "02-connectivity",
    },
  },
  {
    id: "LES-0017",
    path: join(
      repositoryRoot,
      "book",
      "volumes",
      "03-engineering-delivery",
      "LES-0017-bash-safe-automation",
      "lesson.md",
    ),
    expected: {
      aliases: ["V03-L02", "bash-safe-automation"],
      curriculumIds: ["AUT-001"],
      prerequisiteCurriculumIds: ["SCM-001", "LNX-002"],
      prerequisiteLessonIds: ["LES-0009", "LES-0002"],
      order: 2,
      route: "/book/engineering/bash-safe-automation",
      slug: "bash-safe-automation",
      volume: "03-engineering-delivery",
    },
  },
  {
    id: "LES-0018",
    path: join(
      repositoryRoot,
      "book",
      "volumes",
      "03-engineering-delivery",
      "LES-0018-python-operational-automation",
      "lesson.md",
    ),
    expected: {
      aliases: ["V03-L03", "python-operational-automation"],
      curriculumIds: ["AUT-002"],
      prerequisiteCurriculumIds: ["SCM-001", "AUT-001"],
      prerequisiteLessonIds: ["LES-0009", "LES-0017"],
      order: 3,
      route: "/book/engineering/python-operational-automation",
      slug: "python-operational-automation",
      volume: "03-engineering-delivery",
    },
  },
  {
    id: "LES-0019",
    path: join(
      repositoryRoot,
      "book",
      "volumes",
      "03-engineering-delivery",
      "LES-0019-powershell-safe-automation",
      "lesson.md",
    ),
    expected: {
      aliases: ["V03-L04", "powershell-safe-automation"],
      curriculumIds: ["AUT-003"],
      prerequisiteCurriculumIds: ["SCM-001", "AUT-001"],
      prerequisiteLessonIds: ["LES-0009", "LES-0017"],
      order: 4,
      route: "/book/engineering/powershell-safe-automation",
      slug: "powershell-safe-automation",
      volume: "03-engineering-delivery",
    },
  },
  {
    id: "LES-0020",
    path: join(
      repositoryRoot,
      "book",
      "volumes",
      "03-engineering-delivery",
      "LES-0020-go-infrastructure-tooling",
      "lesson.md",
    ),
    expected: {
      aliases: ["V03-L05", "go-infrastructure-tooling"],
      curriculumIds: ["AUT-004"],
      prerequisiteCurriculumIds: ["SCM-001", "AUT-002"],
      prerequisiteLessonIds: ["LES-0009", "LES-0018"],
      order: 5,
      route: "/book/engineering/go-infrastructure-tooling",
      slug: "go-infrastructure-tooling",
      volume: "03-engineering-delivery",
    },
  },
  {
    id: "LES-0021",
    path: join(
      repositoryRoot,
      "book",
      "volumes",
      "03-engineering-delivery",
      "LES-0021-api-contracts-serialization",
      "lesson.md",
    ),
    expected: {
      aliases: ["V03-L06", "api-contracts-serialization"],
      curriculumIds: ["AUT-005"],
      prerequisiteCurriculumIds: ["NET-005", "AUT-002"],
      prerequisiteLessonIds: ["LES-0015", "LES-0018"],
      order: 6,
      route: "/book/engineering/api-contracts-serialization",
      slug: "api-contracts-serialization",
      volume: "03-engineering-delivery",
    },
  },
  {
    id: "LES-0022",
    path: join(
      repositoryRoot,
      "book",
      "volumes",
      "03-engineering-delivery",
      "LES-0022-reproducible-builds-dependencies",
      "lesson.md",
    ),
    expected: {
      aliases: ["V03-L07", "reproducible-builds-dependencies"],
      curriculumIds: ["BLD-001"],
      prerequisiteCurriculumIds: ["SCM-001", "AUT-005"],
      prerequisiteLessonIds: ["LES-0009", "LES-0021"],
      order: 7,
      route: "/book/engineering/reproducible-builds-dependencies",
      slug: "reproducible-builds-dependencies",
      volume: "03-engineering-delivery",
    },
  },
  {
    id: "LES-0023",
    path: join(
      repositoryRoot,
      "book",
      "volumes",
      "03-engineering-delivery",
      "LES-0023-oci-containers-docker",
      "lesson.md",
    ),
    expected: {
      aliases: ["V03-L08", "oci-containers-docker"],
      curriculumIds: ["CTR-001", "CTR-002"],
      prerequisiteCurriculumIds: ["LNX-007", "NET-003", "BLD-001"],
      prerequisiteLessonIds: ["LES-0011", "LES-0004", "LES-0022"],
      order: 8,
      route: "/book/engineering/oci-containers-docker",
      slug: "oci-containers-docker",
      volume: "03-engineering-delivery",
    },
  },
  {
    id: "LES-0024",
    path: join(
      repositoryRoot,
      "book",
      "volumes",
      "03-engineering-delivery",
      "LES-0024-ci-cd-architecture",
      "lesson.md",
    ),
    expected: {
      aliases: ["V03-L09", "ci-cd-architecture"],
      curriculumIds: ["CI-001"],
      prerequisiteCurriculumIds: ["SCM-001", "AUT-005", "BLD-001", "CTR-001", "CTR-002"],
      prerequisiteLessonIds: ["LES-0009", "LES-0021", "LES-0022", "LES-0023"],
      order: 9,
      route: "/book/engineering/ci-cd-architecture",
      slug: "ci-cd-architecture",
      volume: "03-engineering-delivery",
    },
  },
  {
    id: "LES-0025",
    path: join(
      repositoryRoot,
      "book",
      "volumes",
      "03-engineering-delivery",
      "LES-0025-ci-platform-operations",
      "lesson.md",
    ),
    expected: {
      aliases: ["V03-L10", "ci-platform-operations"],
      curriculumIds: ["CI-002"],
      prerequisiteCurriculumIds: ["CI-001"],
      prerequisiteLessonIds: ["LES-0024"],
      order: 10,
      route: "/book/engineering/ci-platform-operations",
      slug: "ci-platform-operations",
      volume: "03-engineering-delivery",
    },
  },
  {
    id: "LES-0026",
    path: join(
      repositoryRoot,
      "book",
      "volumes",
      "04-reliability-operations",
      "LES-0026-observability-foundations",
      "lesson.md",
    ),
    expected: {
      aliases: ["V04-L01", "observability-foundations"],
      curriculumIds: ["OBS-001"],
      prerequisiteCurriculumIds: ["FND-001", "DBG-001"],
      prerequisiteLessonIds: ["LES-0008"],
      order: 1,
      route: "/book/reliability/observability-foundations",
      slug: "observability-foundations",
      volume: "04-reliability-operations",
    },
  },
];
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

function mutateLessonMetadata(raw, mutate) {
  const frontMatter = raw.match(/^---\r?\n([\s\S]+?)\r?\n---\r?\n/);
  assert.ok(frontMatter, "lesson fixture must contain JSON front matter");
  const metadata = JSON.parse(frontMatter[1]);
  mutate(metadata);
  return raw.replace(frontMatter[0], `---\n${JSON.stringify(metadata, null, 2)}\n---\n`);
}

function loadLiveStructuredBundle(id) {
  const descriptor = liveLessonDescriptors.find((candidate) => candidate.id === id);
  if (!descriptor) throw new Error(`unknown live structured lesson fixture: ${id}`);
  const lesson = parseStructuredLesson(readFileSync(descriptor.path, "utf8"));
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
  return { descriptor, lesson, assessments, references };
}

function loadLiveStructuredBundles() {
  return liveLessonDescriptors.map(({ id }) => loadLiveStructuredBundle(id));
}

function liveProductionSearchDocuments() {
  const structured = loadLiveStructuredBundles().map(createStructuredSearchDocument);
  const structuredIds = new Set(structured.map((document) => document.id));
  return [
    ...legacySearchDocuments.filter((document) => !structuredIds.has(document.id)),
    ...structured,
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
    volumeNumber: "01",
    volumeTitle: "Linux systems",
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
    volumeNumber: "01",
    volumeTitle: "Linux systems",
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
    volumeNumber: "01",
    volumeTitle: "Linux systems",
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
    volumeNumber: "99",
    volumeTitle: "Test fixtures",
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

test("twenty-one live structured lessons preserve exact identities and canonical sections", () => {
  const bundles = loadLiveStructuredBundles();
  assert.equal(bundles.length, 21);
  assert.deepEqual(
    bundles.map(({ lesson }) => lesson.metadata.id),
    ["LES-0007", "LES-0008", "LES-0009", "LES-0006", "LES-0010", "LES-0011", "LES-0012", "LES-0013", "LES-0014", "LES-0015", "LES-0016", "LES-0017", "LES-0018", "LES-0019", "LES-0020", "LES-0021", "LES-0022", "LES-0023", "LES-0024", "LES-0025", "LES-0026"],
  );

  for (const { descriptor, lesson, assessments, references } of bundles) {
    assert.equal(lesson.metadata.id, descriptor.id);
    for (const field of ["slug", "route", "order", "volume"]) {
      assert.equal(lesson.metadata[field], descriptor.expected[field], `${descriptor.id} ${field}`);
    }
    assert.deepEqual(lesson.metadata.aliases, descriptor.expected.aliases);
    assert.deepEqual(lesson.metadata.curriculumIds, descriptor.expected.curriculumIds);
    assert.deepEqual(
      lesson.metadata.prerequisiteLessonIds,
      descriptor.expected.prerequisiteLessonIds,
    );
    assert.deepEqual(
      lesson.metadata.prerequisiteCurriculumIds,
      descriptor.expected.prerequisiteCurriculumIds,
    );
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
  }
});

test("runtime lesson parsing rejects missing or non-array prerequisites with stable diagnostics", () => {
  const lesson0008 = liveLessonDescriptors.find(({ id }) => id === "LES-0008");
  assert.ok(lesson0008);
  const liveRaw = readFileSync(lesson0008.path, "utf8");

  for (const field of ["prerequisiteLessonIds", "prerequisiteCurriculumIds"]) {
    const missing = mutateLessonMetadata(liveRaw, (metadata) => {
      delete metadata[field];
    });
    assert.throws(
      () => parseStructuredLesson(missing),
      new RegExp(`lesson\\.${field} must be an array of strings`),
      `${field} must be required at the runtime boundary`,
    );

    const nonArray = mutateLessonMetadata(liveRaw, (metadata) => {
      metadata[field] = "not-an-array";
    });
    assert.throws(
      () => parseStructuredLesson(nonArray),
      new RegExp(`lesson\\.${field} must be an array of strings`),
      `${field} must reject scalar input at the runtime boundary`,
    );
  }
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

  const lesson0006 = liveLessonDescriptors.find(({ id }) => id === "LES-0006");
  const liveRaw = readFileSync(lesson0006.path, "utf8");
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

test("runtime title and section parsing matches the validated ATX heading rules", () => {
  const lesson0007 = liveLessonDescriptors.find(({ id }) => id === "LES-0007");
  const liveRaw = readFileSync(lesson0007.path, "utf8");
  const title = loadLiveStructuredBundle("LES-0007").lesson.metadata.title;
  const aligned = liveRaw
    .replace(`# ${title}`, `   # ${title} ###`)
    .replace("## What you see and first thought", "   ## What you see and first thought ###");
  const parsed = parseStructuredLesson(aligned);
  assert.equal(parsed.title, title);
  assert.deepEqual(
    parsed.sections.map((section) => section.title),
    [...REQUIRED_STRUCTURED_SECTIONS],
  );

  const fencedFake = liveRaw.replace(
    `# ${title}`,
    `# ${title}\n\n~~~text\n# fenced fake title\n~~~`,
  );
  assert.equal(parseStructuredLesson(fencedFake).title, title);
  const commentedFake = liveRaw.replace(
    `# ${title}`,
    `# ${title}\n\n<!--\n# commented fake title\n-->`,
  );
  assert.equal(parseStructuredLesson(commentedFake).title, title);
  assert.throws(
    () => parseStructuredLesson(liveRaw.replace(`# ${title}`, `# ${title}\n\n# duplicate`)),
    /exactly one level-one title/,
  );
  assert.throws(
    () => parseStructuredLesson(liveRaw.replace(`# ${title}`, "# different title")),
    /must exactly match metadata.title/,
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

test("the volume-aware reader catalog publishes twenty-six stable identities across five volumes", () => {
  const linuxVolume = getReaderVolume("01-linux-systems");
  assert.deepEqual(getReaderVolume("04-reliability-operations"), {
    volumeId: "04-reliability-operations",
    volumeNumber: "04",
    volumeTitle: "Reliability and operations",
    volumeRoute: "/book/reliability",
  });
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
    ...linuxVolume,
    order: index + 1,
    number: String(index + 1).padStart(2, "0"),
    title: lesson.slug,
    summary: `Reserved reader identity for ${lesson.id}`,
    aliases: lesson.aliases,
    curriculumIds: lesson.curriculumIds,
    renderKind: index === 0 ? "legacy-storage" : "legacy-foundation",
    availability: index === 0 ? "practical-gate" : "ready-to-study",
  }));
  const structuredMetadata = loadLiveStructuredBundles().map(({ lesson }) => lesson.metadata);
  const catalog = createReaderCatalog(legacyEntries, structuredMetadata);

  assert.equal(catalog.length, 26);
  assert.deepEqual(
    catalog.map((entry) => [
      entry.canonicalId,
      entry.stateId,
      entry.route,
      entry.volumeId,
      entry.order,
    ]),
    [
      ["LES-0007", "LES-0007", "/book/start/systems-thinking", "00-start-safely", 1],
      ["LES-0008", "LES-0008", "/book/start/evidence-driven-troubleshooting", "00-start-safely", 2],
      ...expectedLegacyIdentities.map(([id, stateId, route], index) =>
        [id, stateId, route, "01-linux-systems", index + 1]),
      ["LES-0006", "LES-0006", "/book/linux/boot-kernel-systemd-journal", "01-linux-systems", 6],
      ["LES-0010", "LES-0010", "/book/linux/block-io-storage-performance", "01-linux-systems", 7],
      ["LES-0011", "LES-0011", "/book/linux/namespaces-cgroups-isolation", "01-linux-systems", 8],
      ["LES-0012", "LES-0012", "/book/connectivity/ethernet-ip-cidr-routing-nat", "02-connectivity", 1],
      ["LES-0013", "LES-0013", "/book/connectivity/tcp-udp-sockets-exhaustion", "02-connectivity", 2],
      ["LES-0014", "LES-0014", "/book/connectivity/dns-service-discovery", "02-connectivity", 3],
      ["LES-0015", "LES-0015", "/book/connectivity/http-proxies-load-balancing", "02-connectivity", 4],
      ["LES-0016", "LES-0016", "/book/connectivity/tls-pki-mtls-rotation", "02-connectivity", 5],
      ["LES-0009", "LES-0009", "/book/engineering/safe-local-workbench", "03-engineering-delivery", 1],
      ["LES-0017", "LES-0017", "/book/engineering/bash-safe-automation", "03-engineering-delivery", 2],
      ["LES-0018", "LES-0018", "/book/engineering/python-operational-automation", "03-engineering-delivery", 3],
      ["LES-0019", "LES-0019", "/book/engineering/powershell-safe-automation", "03-engineering-delivery", 4],
      ["LES-0020", "LES-0020", "/book/engineering/go-infrastructure-tooling", "03-engineering-delivery", 5],
      ["LES-0021", "LES-0021", "/book/engineering/api-contracts-serialization", "03-engineering-delivery", 6],
      ["LES-0022", "LES-0022", "/book/engineering/reproducible-builds-dependencies", "03-engineering-delivery", 7],
      ["LES-0023", "LES-0023", "/book/engineering/oci-containers-docker", "03-engineering-delivery", 8],
      ["LES-0024", "LES-0024", "/book/engineering/ci-cd-architecture", "03-engineering-delivery", 9],
      ["LES-0025", "LES-0025", "/book/engineering/ci-platform-operations", "03-engineering-delivery", 10],
      ["LES-0026", "LES-0026", "/book/reliability/observability-foundations", "04-reliability-operations", 1],
    ],
  );
  for (const field of ["canonicalId", "stateId", "slug", "route"]) {
    const values = catalog.map((entry) => String(entry[field]));
    assert.equal(new Set(values).size, 26, `${field} must be unique`);
  }
  assert.equal(new Set(catalog.map((entry) => entry.volumeId)).size, 5);
  const positions = catalog.map((entry) => `${entry.volumeId}:${entry.order}`);
  assert.equal(
    findReaderEntryByCanonicalIdInCatalog(catalog, "LES-0002")?.route,
    "/book/linux/processes-signals-systemd",
  );
  assert.equal(
    findReaderEntryByCanonicalIdInCatalog(catalog, "LES-0007")?.route,
    "/book/start/systems-thinking",
  );
  assert.equal(
    findReaderEntryByCanonicalIdInCatalog(catalog, "LES-0008")?.route,
    "/book/start/evidence-driven-troubleshooting",
  );
  assert.equal(findReaderEntryByCanonicalIdInCatalog(catalog, "LES-9000"), undefined);

  const bootLessonForPrerequisites = structuredMetadata.find(({ id }) => id === "LES-0006");
  assert.ok(bootLessonForPrerequisites);
  const bootPrerequisites = resolveReaderPrerequisitesInCatalog(
    catalog,
    bootLessonForPrerequisites.prerequisiteLessonIds,
    bootLessonForPrerequisites.prerequisiteCurriculumIds,
  );
  assert.deepEqual(
    bootPrerequisites.lessons.map((entry) => [entry.canonicalId, entry.stateId, entry.route]),
    [["LES-0002", "processes-signals-systemd", "/book/linux/processes-signals-systemd"]],
  );
  assert.deepEqual(bootPrerequisites.curriculumIds, ["LNX-002"]);

  const frameLessonForPrerequisites = structuredMetadata.find(({ id }) => id === "LES-0008");
  assert.ok(frameLessonForPrerequisites);
  const framePrerequisites = resolveReaderPrerequisitesInCatalog(
    catalog,
    frameLessonForPrerequisites.prerequisiteLessonIds,
    frameLessonForPrerequisites.prerequisiteCurriculumIds,
  );
  assert.deepEqual(
    framePrerequisites.lessons.map((entry) => [entry.canonicalId, entry.stateId, entry.route]),
    [["LES-0007", "LES-0007", "/book/start/systems-thinking"]],
  );
  assert.deepEqual(framePrerequisites.curriculumIds, ["FND-001"]);

  const systemsLessonForPrerequisites = structuredMetadata.find(({ id }) => id === "LES-0007");
  assert.ok(systemsLessonForPrerequisites);
  assert.deepEqual(
    resolveReaderPrerequisitesInCatalog(
      catalog,
      systemsLessonForPrerequisites.prerequisiteLessonIds,
      systemsLessonForPrerequisites.prerequisiteCurriculumIds,
    ),
    { lessons: [], curriculumIds: [] },
  );
  assert.throws(
    () => resolveReaderPrerequisitesInCatalog(catalog, ["LES-9000"], []),
    /reader prerequisite LES-9000 is missing from the catalog/,
  );
  assert.equal(new Set(positions).size, 26, "volume-local positions must be unique");
  assert.equal(new Set(catalog.map((entry) => entry.order)).size, 10,
    "the same local order is valid in different volumes");
  assert.equal(catalog.find((entry) => entry.canonicalId === "LES-0007").availability,
    "substantive-draft");
  assert.equal(catalog.find((entry) => entry.canonicalId === "LES-0008").availability,
    "substantive-draft");
  const lesson0006 = structuredMetadata.find(({ id }) => id === "LES-0006");
  assert.throws(
    () => createReaderCatalog(legacyEntries, [{
      ...lesson0006,
      route: "/book/linux/storage",
    }]),
    /duplicate route/,
  );
  const lesson0007 = structuredMetadata.find(({ id }) => id === "LES-0007");
  assert.throws(
    () => createReaderCatalog(legacyEntries, [{
      ...lesson0007,
      id: "LES-9000",
      aliases: ["V01-L99", "volume-order-collision"],
      slug: "volume-order-collision",
      route: "/book/linux/volume-order-collision",
      volume: "01-linux-systems",
      order: 1,
    }]),
    /duplicate volume order/,
  );
  const startBoundary = adjacentReaderEntriesInCatalog(catalog, "systems-thinking");
  assert.equal(startBoundary.previous, undefined);
  assert.equal(startBoundary.next?.canonicalId, "LES-0008");
  const startEnd = adjacentReaderEntriesInCatalog(catalog, "evidence-driven-troubleshooting");
  assert.equal(startEnd.previous?.canonicalId, "LES-0007");
  assert.equal(startEnd.next, undefined);
  const linuxStart = adjacentReaderEntriesInCatalog(catalog, "storage");
  assert.equal(linuxStart.previous, undefined);
  assert.equal(linuxStart.next?.canonicalId, "LES-0002");
  const linuxEnd = adjacentReaderEntriesInCatalog(
    catalog,
    "namespaces-cgroups-isolation",
  );
  assert.equal(linuxEnd.previous?.canonicalId, "LES-0010");
  assert.equal(linuxEnd.next, undefined);
  const connectivityStart = adjacentReaderEntriesInCatalog(catalog, "ethernet-ip-cidr-routing-nat");
  assert.equal(connectivityStart.previous, undefined);
  assert.equal(connectivityStart.next?.canonicalId, "LES-0013");
  const connectivityMiddle = adjacentReaderEntriesInCatalog(catalog, "tcp-udp-sockets-exhaustion");
  assert.equal(connectivityMiddle.previous?.canonicalId, "LES-0012");
  assert.equal(connectivityMiddle.next?.canonicalId, "LES-0014");
  const connectivityDns = adjacentReaderEntriesInCatalog(catalog, "dns-service-discovery");
  assert.equal(connectivityDns.previous?.canonicalId, "LES-0013");
  assert.equal(connectivityDns.next?.canonicalId, "LES-0015");
  const connectivityHttp = adjacentReaderEntriesInCatalog(catalog, "http-proxies-load-balancing");
  assert.equal(connectivityHttp.previous?.canonicalId, "LES-0014");
  assert.equal(connectivityHttp.next?.canonicalId, "LES-0016");
  const connectivityEnd = adjacentReaderEntriesInCatalog(catalog, "tls-pki-mtls-rotation");
  assert.equal(connectivityEnd.previous?.canonicalId, "LES-0015");
  assert.equal(connectivityEnd.next, undefined);
  const engineeringStart = adjacentReaderEntriesInCatalog(catalog, "safe-local-workbench");
  assert.equal(engineeringStart.previous, undefined);
  assert.equal(engineeringStart.next?.canonicalId, "LES-0017");
  const engineeringMiddle = adjacentReaderEntriesInCatalog(catalog, "bash-safe-automation");
  assert.equal(engineeringMiddle.previous?.canonicalId, "LES-0009");
  assert.equal(engineeringMiddle.next?.canonicalId, "LES-0018");
  const engineeringPython = adjacentReaderEntriesInCatalog(catalog, "python-operational-automation");
  assert.equal(engineeringPython.previous?.canonicalId, "LES-0017");
  assert.equal(engineeringPython.next?.canonicalId, "LES-0019");
  const engineeringPowerShell = adjacentReaderEntriesInCatalog(catalog, "powershell-safe-automation");
  assert.equal(engineeringPowerShell.previous?.canonicalId, "LES-0018");
  assert.equal(engineeringPowerShell.next?.canonicalId, "LES-0020");
  const engineeringGo = adjacentReaderEntriesInCatalog(catalog, "go-infrastructure-tooling");
  assert.equal(engineeringGo.previous?.canonicalId, "LES-0019");
  assert.equal(engineeringGo.next?.canonicalId, "LES-0021");
  const engineeringApi = adjacentReaderEntriesInCatalog(catalog, "api-contracts-serialization");
  assert.equal(engineeringApi.previous?.canonicalId, "LES-0020");
  assert.equal(engineeringApi.next?.canonicalId, "LES-0022");
  const engineeringBuilds = adjacentReaderEntriesInCatalog(
    catalog,
    "reproducible-builds-dependencies",
  );
  assert.equal(engineeringBuilds.previous?.canonicalId, "LES-0021");
  assert.equal(engineeringBuilds.next?.canonicalId, "LES-0023");
  const engineeringEnd = adjacentReaderEntriesInCatalog(catalog, "oci-containers-docker");
  assert.equal(engineeringEnd.previous?.canonicalId, "LES-0022");
  assert.equal(engineeringEnd.next?.canonicalId, "LES-0024");
  const engineeringCiCd = adjacentReaderEntriesInCatalog(catalog, "ci-cd-architecture");
  assert.equal(engineeringCiCd.previous?.canonicalId, "LES-0023");
  assert.equal(engineeringCiCd.next?.canonicalId, "LES-0025");
  const engineeringCiPlatforms = adjacentReaderEntriesInCatalog(
    catalog,
    "ci-platform-operations",
  );
  assert.equal(engineeringCiPlatforms.previous?.canonicalId, "LES-0024");
  assert.equal(engineeringCiPlatforms.next, undefined);
  const reliabilityStart = adjacentReaderEntriesInCatalog(catalog, "observability-foundations");
  assert.equal(reliabilityStart.previous, undefined);
  assert.equal(reliabilityStart.next, undefined);
});

test("an eight-entry v1 reading state gains eighteen lessons without prior state loss", () => {
  const legacyStateIds = expectedLegacyIdentities.map(([, stateId]) => stateId);
  const priorStateIds = [...legacyStateIds, "LES-0006", "LES-0007", "LES-0008"];
  const priorLessons = Object.fromEntries(priorStateIds.map((lessonId, index) => [
    lessonId,
    {
      bookmarked: index % 2 === 0,
      marker: index === 5 ? "finished-reading" : "reading",
      lastOpenedAt: `2026-08-02T00:0${index}:00.000Z`,
    },
  ]));
  const loaded = loadLearningState(new MemoryStorage(JSON.stringify({
    version: 1,
    recentLessonIds: ["LES-0007", "LES-0006", "identity-permissions", "storage"],
    lessons: priorLessons,
  })));

  assert.equal(loaded.recoveredInvalidData, false);
  assert.deepEqual(
    [...LEARNING_LIBRARY_LESSON_IDS],
    [...priorStateIds, "LES-0009", "LES-0010", "LES-0011", "LES-0012", "LES-0013", "LES-0014", "LES-0015", "LES-0016", "LES-0017", "LES-0018", "LES-0019", "LES-0020", "LES-0021", "LES-0022", "LES-0023", "LES-0024", "LES-0025", "LES-0026"],
  );
  assert.deepEqual(
    loaded.state.recentLessonIds,
    ["LES-0007", "LES-0006", "identity-permissions", "storage"],
  );
  for (const lessonId of priorStateIds) {
    assert.deepEqual(loaded.state.lessons[lessonId], priorLessons[lessonId]);
  }
  for (const lessonId of ["LES-0009", "LES-0010", "LES-0011", "LES-0012", "LES-0013", "LES-0014", "LES-0015", "LES-0016", "LES-0017", "LES-0018", "LES-0019", "LES-0020", "LES-0021", "LES-0022", "LES-0023", "LES-0024", "LES-0025", "LES-0026"]) {
    assert.deepEqual(loaded.state.lessons[lessonId], {
      bookmarked: false,
      marker: "not-started",
      lastOpenedAt: null,
    });
  }
});

test("structured bookmarks and finished-reading markers never create mastery data", () => {
  for (const [lessonId, openedAt] of [
    ["LES-0006", "2026-08-02T06:00:00.000Z"],
    ["LES-0007", "2026-08-02T07:00:00.000Z"],
    ["LES-0008", "2026-08-02T08:00:00.000Z"],
    ["LES-0009", "2026-08-02T09:00:00.000Z"],
    ["LES-0010", "2026-08-02T10:00:00.000Z"],
    ["LES-0011", "2026-08-02T11:00:00.000Z"],
    ["LES-0012", "2026-08-02T12:00:00.000Z"],
    ["LES-0013", "2026-08-02T13:00:00.000Z"],
    ["LES-0014", "2026-08-02T14:00:00.000Z"],
    ["LES-0015", "2026-08-02T15:00:00.000Z"],
    ["LES-0016", "2026-08-02T16:00:00.000Z"],
    ["LES-0017", "2026-08-02T17:00:00.000Z"],
    ["LES-0018", "2026-08-02T18:00:00.000Z"],
    ["LES-0019", "2026-08-02T19:00:00.000Z"],
    ["LES-0020", "2026-08-02T20:00:00.000Z"],
    ["LES-0021", "2026-08-02T21:00:00.000Z"],
    ["LES-0022", "2026-08-02T22:00:00.000Z"],
    ["LES-0023", "2026-08-02T23:00:00.000Z"],
    ["LES-0024", "2026-08-03T00:00:00.000Z"],
    ["LES-0025", "2026-08-03T01:00:00.000Z"],
    ["LES-0026", "2026-08-03T02:00:00.000Z"],
  ]) {
    const initial = createEmptyLearningState();
    const bookmarked = toggleLessonBookmark(initial, lessonId);
    const finished = setLessonMarker(bookmarked, lessonId, "finished-reading");
    const opened = recordLessonOpened(finished, lessonId, openedAt);

    assert.deepEqual(opened.lessons[lessonId], {
      bookmarked: true,
      marker: "finished-reading",
      lastOpenedAt: openedAt,
    });
    assert.equal(opened.recentLessonIds[0], lessonId);
    assert.equal(Object.hasOwn(opened.lessons[lessonId], "mastery"), false);
    assert.equal(Object.hasOwn(opened, "mastery"), false);
    assert.deepEqual(opened.lessons.storage, initial.lessons.storage);
  }
});

test("the live production search set has twenty-six unique lessons and stable golden rankings", () => {
  const documents = liveProductionSearchDocuments();
  assert.deepEqual(
    documents.map((document) => document.id),
    [
      "storage",
      "processes-signals-systemd",
      "cpu-memory-pressure",
      "network-request-path",
      "identity-permissions",
      "LES-0007",
      "LES-0008",
      "LES-0009",
      "LES-0006",
      "LES-0010",
      "LES-0011",
      "LES-0012",
      "LES-0013",
      "LES-0014",
      "LES-0015",
      "LES-0016",
      "LES-0017",
      "LES-0018",
      "LES-0019",
      "LES-0020",
      "LES-0021",
      "LES-0022",
      "LES-0023",
      "LES-0024",
      "LES-0025",
      "LES-0026",
    ],
  );
  assert.equal(new Set(documents.map((document) => document.id)).size, 26);
  assert.equal(new Set(documents.map((document) => document.href)).size, 26);
  assert.equal(documents.find((document) => document.id === "LES-0007")?.volumeNumber, "00");
  assert.equal(documents.find((document) => document.id === "LES-0007")?.volumeTitle, "Start safely");
  assert.equal(documents.find((document) => document.id === "LES-0008")?.volumeNumber, "00");
  assert.equal(documents.find((document) => document.id === "LES-0008")?.volumeTitle, "Start safely");
  assert.equal(documents.find((document) => document.id === "LES-0009")?.volumeNumber, "03");
  assert.equal(documents.find((document) => document.id === "LES-0009")?.volumeTitle, "Engineering and delivery");
  assert.equal(documents.find((document) => document.id === "LES-0026")?.volumeNumber, "04");
  assert.equal(documents.find((document) => document.id === "LES-0026")?.volumeTitle, "Reliability and operations");

  const goldenQueries = new Map([
    ["LES-0001", "storage"],
    ["ENOSPC", "storage"],
    ["df -i", "storage"],
    ["LES-0002", "processes-signals-systemd"],
    ["SIGTERM", "processes-signals-systemd"],
    ["LES-0003", "cpu-memory-pressure"],
    ["exit 137", "cpu-memory-pressure"],
    ["LES-0004", "network-request-path"],
    ["curl -v", "network-request-path"],
    ["LES-0005", "identity-permissions"],
    ["UID 10001", "identity-permissions"],
    ["journalctl boot", "LES-0006"],
    ["clock skew", "LES-0006"],
    ["systemd-analyze critical-chain", "LES-0006"],
    ["LES-0006", "LES-0006"],
    ["V01-L06", "LES-0006"],
    ["LNX-005", "LES-0006"],
    ["queue", "LES-0007"],
    ["backpressure", "LES-0007"],
    ["FND-001", "LES-0007"],
    ["V00-L01", "LES-0007"],
    ["LES-0008", "LES-0008"],
    ["V00-L02", "LES-0008"],
    ["DBG-001", "LES-0008"],
    ["FRAME", "LES-0008"],
    ["LES-0009", "LES-0009"],
    ["V03-L01", "LES-0009"],
    ["SCM-001", "LES-0009"],
    ["LES-0010", "LES-0010"],
    ["V01-L07", "LES-0010"],
    ["LNX-006", "LES-0010"],
    ["LES-0011", "LES-0011"],
    ["V01-L08", "LES-0011"],
    ["LNX-007", "LES-0011"],
    ["LES-0012", "LES-0012"],
    ["V02-L01", "LES-0012"],
    ["NET-001", "LES-0012"],
    ["LES-0013", "LES-0013"],
    ["V02-L02", "LES-0013"],
    ["NET-007", "LES-0013"],
    ["LES-0014", "LES-0014"],
    ["V02-L03", "LES-0014"],
    ["NET-004", "LES-0014"],
    ["LES-0015", "LES-0015"],
    ["V02-L04", "LES-0015"],
    ["NET-005", "LES-0015"],
    ["LES-0016", "LES-0016"],
    ["V02-L05", "LES-0016"],
    ["NET-006", "LES-0016"],
    ["LES-0017", "LES-0017"],
    ["V03-L02", "LES-0017"],
    ["AUT-001", "LES-0017"],
    ["LES-0018", "LES-0018"],
    ["V03-L03", "LES-0018"],
    ["AUT-002", "LES-0018"],
    ["LES-0019", "LES-0019"],
    ["V03-L04", "LES-0019"],
    ["AUT-003", "LES-0019"],
    ["LES-0020", "LES-0020"],
    ["V03-L05", "LES-0020"],
    ["AUT-004", "LES-0020"],
    ["LES-0021", "LES-0021"],
    ["V03-L06", "LES-0021"],
    ["AUT-005", "LES-0021"],
    ["LES-0022", "LES-0022"],
    ["V03-L07", "LES-0022"],
    ["BLD-001", "LES-0022"],
    ["LES-0023", "LES-0023"],
    ["V03-L08", "LES-0023"],
    ["CTR-001", "LES-0023"],
    ["CTR-002", "LES-0023"],
    ["LES-0024", "LES-0024"],
    ["V03-L09", "LES-0024"],
    ["CI-001", "LES-0024"],
    ["ci-cd-architecture", "LES-0024"],
    ["LES-0025", "LES-0025"],
    ["V03-L10", "LES-0025"],
    ["CI-002", "LES-0025"],
    ["ci-platform-operations", "LES-0025"],
    ["LES-0026", "LES-0026"],
    ["V04-L01", "LES-0026"],
    ["OBS-001", "LES-0026"],
    ["observability-foundations", "LES-0026"],
  ]);
  for (const [query, expectedId] of goldenQueries) {
    const results = searchLessons(documents, query);
    assert.equal(results[0]?.document.id, expectedId, `unexpected top result for ${query}`);
  }
});

test("navigation search documents keep career and interview destinations discoverable", () => {
  assert.equal(searchLessons(navigationSearchDocuments, "interview")[0]?.document.href, "/practice/interview");
  assert.equal(searchLessons(navigationSearchDocuments, "career map")[0]?.document.href, "/career");
});

test("all twenty-one independent transfers stay answer-isolated from their answered records", () => {
  const expectedIndependentIds = new Map([
    ["LES-0006", "ASM-0003"],
    ["LES-0007", "ASM-0006"],
    ["LES-0008", "ASM-0009"],
    ["LES-0009", "ASM-0012"],
    ["LES-0010", "ASM-0015"],
    ["LES-0011", "ASM-0018"],
    ["LES-0012", "ASM-0021"],
    ["LES-0013", "ASM-0024"],
    ["LES-0014", "ASM-0027"],
    ["LES-0015", "ASM-0030"],
    ["LES-0016", "ASM-0033"],
    ["LES-0017", "ASM-0036"],
    ["LES-0018", "ASM-0039"],
    ["LES-0019", "ASM-0042"],
    ["LES-0020", "ASM-0045"],
    ["LES-0021", "ASM-0048"],
    ["LES-0022", "ASM-0051"],
    ["LES-0023", "ASM-0054"],
    ["LES-0024", "ASM-0057"],
    ["LES-0025", "ASM-0060"],
    ["LES-0026", "ASM-0063"],
  ]);
  for (const { lesson, assessments } of loadLiveStructuredBundles()) {
    const independent = assessments.filter((assessment) =>
      assessment.type === "independent-transfer");
    const answered = assessments.filter((assessment) =>
      assessment.type !== "independent-transfer");

    assert.equal(independent.length, 1, `${lesson.metadata.id} independent count`);
    assert.equal(answered.length, 2, `${lesson.metadata.id} answered count`);
    assert.equal(independent[0].id, expectedIndependentIds.get(lesson.metadata.id));
    assert.equal(independent[0].reviewPolicy, "reviewer-only-no-model-answer");
    assert.ok(independent[0].deliverables.length > 0);

    assert.ok(independent[0].evidenceRequirements.length > 0);
    for (const field of independentAnswerFields) {
      assert.equal(Object.hasOwn(independent[0], field), false,
        `${independent[0].id} leaked ${field}`);
    }
    for (const assessment of answered) {
      for (const field of independentAnswerFields) {
        assert.equal(Object.hasOwn(assessment, field), true,
          `${assessment.id} is missing ${field}`);
      }
    }
  }
});

test("search tie-breaking is stable across volume-local lesson numbers", () => {
  const tied = searchLessons([
    { ...searchFixture[0], id: "volume-01", volumeNumber: "01", number: "01" },
    { ...searchFixture[0], id: "volume-00", volumeNumber: "00", number: "01" },
  ], "df -i");
  assert.deepEqual(tied.map(({ document }) => document.id), ["volume-00", "volume-01"]);
});

test("virtual lesson modules reject unknown IDs and load only registered canonical files", async () => {
  const plugin = bookContent();
  plugin.configResolved({ root: join(repositoryRoot, "learning-cockpit") });
  assert.equal(plugin.resolveId("unrelated-module"), null);
  assert.throws(
    () => plugin.resolveId("virtual:book-lesson/../README"),
    /unregistered virtual lesson module/,
  );
  await assert.rejects(
    () => plugin.load("\0virtual:book-lesson/../README"),
    /unregistered resolved lesson module/,
  );

  for (const descriptor of liveLessonDescriptors) {
    const publicId = `virtual:book-lesson/${descriptor.id}`;
    const resolvedId = `\0${publicId}`;
    assert.equal(plugin.resolveId(publicId), resolvedId);

    const watched = [];
    const loaded = await plugin.load.call({
      addWatchFile(path) {
        watched.push(path);
      },
    }, resolvedId);
    const expectedSource = readFileSync(descriptor.path, "utf8");
    assert.deepEqual(watched, [descriptor.path]);
    assert.equal(loaded.code, `export default ${JSON.stringify(expectedSource)};`);
  }
  assert.equal(await plugin.load.call({ addWatchFile() {} }, "unrelated-module"), null);
});
