import assert from "node:assert/strict";
import {
  existsSync, mkdirSync, mkdtempSync, readFileSync, renameSync, rmSync, symlinkSync,
  writeFileSync,
} from "node:fs";
import { tmpdir } from "node:os";
import { dirname, join, resolve } from "node:path";
import test from "node:test";
import { fileURLToPath } from "node:url";

import {
  collectCurriculumIdsFromMarkdown,
  parseJsonFrontMatter,
  validateAssessmentRecord,
  validateJsonSchemaValue,
  validateLessonDocument,
  validateReferenceRecord,
  validateRepositoryStructuredContent,
  validateSchemaDocument,
} from "../lib/structured-content.mjs";

const testDirectory = dirname(fileURLToPath(import.meta.url));
const repositoryRoot = resolve(testDirectory, "..", "..");
const fixtureRoot = join(testDirectory, "fixtures", "content-schema");
const schemaRoot = join(repositoryRoot, "book", "schema");

function textFixture(group, name) {
  return readFileSync(join(fixtureRoot, group, name), "utf8");
}

function jsonFixture(group, name) {
  return JSON.parse(textFixture(group, name));
}

const lessonSchema = JSON.parse(readFileSync(join(schemaRoot, "lesson.schema.json"), "utf8"));
const assessmentSchema = JSON.parse(
  readFileSync(join(schemaRoot, "assessment.schema.json"), "utf8"),
);
const referenceSchema = JSON.parse(
  readFileSync(join(schemaRoot, "reference.schema.json"), "utf8"),
);
const validLessonText = textFixture("valid", "lesson.md.fixture");
const parsedValidLesson = parseJsonFrontMatter(validLessonText);

function lessonText(metadata, body = parsedValidLesson.body) {
  return `---\n${JSON.stringify(metadata, null, 2)}\n---\n${body}`;
}

function clone(value) {
  return structuredClone(value);
}

function codes(issues) {
  return issues.map((entry) => entry.code);
}

const matrixIds = [
  "FND-001", "LNX-001", "LNX-002", "LNX-003", "LNX-004", "LNX-005", "LNX-006",
  "NET-003", "NET-004", "NET-005", "NET-006",
];

function fixtureMatrix() {
  const header = "| ID | Req. | Domain | Prerequisites | Chapters | Labs | Incidents | Capstone | Status | Gaps | Evidence |";
  const divider = "|---|---:|---|---|---|---|---|---|---|---|---|";
  const rows = matrixIds.map((id) =>
    `| ${id} | 1 | Fixture domain | None | Fixture | Fixture | Fixture | None | Planned | Fixture | Fixture |`);
  return ["# Fixture content matrix", "", header, divider, ...rows, ""].join("\n");
}

function replaceIds(value, replacements) {
  let serialized = JSON.stringify(value);
  for (const [from, to] of replacements) serialized = serialized.replaceAll(from, to);
  return JSON.parse(serialized);
}

function createFixtureRepository(options = {}) {
  const root = mkdtempSync(join(tmpdir(), "devops-sre-content-contract-"));
  for (const directory of [
    "book/schema", "book/volumes", "book/assessments/linux", "book/references",
  ]) mkdirSync(join(root, directory), { recursive: true });
  for (const name of ["lesson.schema.json", "assessment.schema.json", "reference.schema.json"]) {
    writeFileSync(join(root, "book", "schema", name),
      readFileSync(join(schemaRoot, name), "utf8"));
  }
  writeFileSync(join(root, "CONTENT_MATRIX.md"), fixtureMatrix());

  const legacyMap = JSON.parse(readFileSync(
    join(schemaRoot, "legacy-content-map.json"), "utf8"));
  writeFileSync(join(root, "book", "schema", "legacy-content-map.json"),
    `${JSON.stringify(legacyMap, null, 2)}\n`);
  for (const source of new Set(legacyMap.lessons.flatMap((lesson) => lesson.sources))) {
    const target = join(root, ...source.split("/"));
    mkdirSync(dirname(target), { recursive: true });
    if (!existsSync(target)) writeFileSync(target, "fixture legacy source\n");
  }

  const firstLesson = clone(parsedValidLesson.metadata);
  firstLesson.prerequisiteLessonIds = ["LES-0001"];
  const firstAssessment = jsonFixture("valid", "assessment.json.fixture");
  const firstReference = jsonFixture("valid", "reference.json.fixture");
  const model = {
    lessons: [firstLesson],
    assessments: [firstAssessment],
    references: [firstReference],
    legacyMap,
  };
  if (options.twoLessons) {
    const replacements = [
      ["LES-9001", "LES-9002"], ["ASM-9001", "ASM-9002"], ["REF-9001", "REF-9002"],
    ];
    const secondLesson = replaceIds(firstLesson, replacements);
    secondLesson.aliases = ["V99-L02", "schema-fixture-two"];
    secondLesson.slug = "schema-fixture-two";
    secondLesson.route = "/book/linux/schema-fixture-two";
    secondLesson.order = 9002;
    secondLesson.curriculumIds = ["LNX-006"];
    secondLesson.prerequisiteCurriculumIds = ["LNX-005"];
    secondLesson.prerequisiteLessonIds = ["LES-9001"];
    model.lessons.push(secondLesson);
    model.assessments.push(replaceIds(firstAssessment, replacements));
    model.references.push(replaceIds(firstReference, replacements));
  }
  options.mutate?.(model);
  writeFileSync(join(root, "book", "schema", "legacy-content-map.json"),
    `${JSON.stringify(model.legacyMap, null, 2)}\n`);

  for (const lesson of model.lessons) {
    const directory = join(root, "book", "volumes", lesson.volume,
      `${lesson.id}-${lesson.slug}`);
    mkdirSync(directory, { recursive: true });
    writeFileSync(join(directory, "lesson.md"), lessonText(lesson));
  }
  for (const assessment of model.assessments) {
    writeFileSync(join(root, "book", "assessments", "linux", `${assessment.id}.json`),
      `${JSON.stringify(assessment, null, 2)}\n`);
  }
  for (const reference of model.references) {
    writeFileSync(join(root, "book", "references", `${reference.id}.json`),
      `${JSON.stringify(reference, null, 2)}\n`);
  }
  return root;
}

function validateFixtureRepository(options = {}) {
  const root = createFixtureRepository(options);
  try {
    return validateRepositoryStructuredContent(root);
  } finally {
    rmSync(root, { recursive: true, force: true });
  }
}

test("valid lesson, assessment, and reference fixtures satisfy version 1", () => {
  assert.deepEqual(validateLessonDocument(validLessonText, lessonSchema).issues, []);
  assert.deepEqual(
    validateAssessmentRecord(jsonFixture("valid", "assessment.json.fixture"), assessmentSchema),
    [],
  );
  assert.deepEqual(
    validateReferenceRecord(jsonFixture("valid", "reference.json.fixture"), referenceSchema),
    [],
  );
});

test("malformed JSON front matter fails with a stable diagnostic", () => {
  const result = validateLessonDocument(
    textFixture("invalid", "malformed-lesson.md.fixture"),
    lessonSchema,
  );
  assert.deepEqual(codes(result.issues), ["FRONT_MATTER_JSON"]);
});

test("duplicate JSON keys are rejected after escape decoding", () => {
  const duplicateRisk = validLessonText.replace(
    '"risk": "read-only",',
    '"risk": "read-only",\n      "r\\u0069sk": "destructive-disposable",',
  );
  assert.deepEqual(
    codes(validateLessonDocument(duplicateRisk, lessonSchema).issues),
    ["JSON_DUPLICATE_KEY"],
  );
});

test("the dependency-free schema engine fails closed", () => {
  assert.ok(codes(validateSchemaDocument({
    type: "object",
    required: "id",
  })).includes("SCHEMA_KEYWORD_VALUE"));

  assert.deepEqual(
    codes(validateJsonSchemaValue(
      { numeric: 42 },
      { type: "object", additionalProperties: { type: "string" } },
    )),
    ["SCHEMA_TYPE"],
  );

  assert.ok(codes(validateSchemaDocument({
    type: "object",
    properties: { optional: { $ref: "#/$defs/missing" } },
  })).includes("SCHEMA_REF_UNRESOLVED"));

  const recursive = {
    type: "object",
    properties: { child: { $ref: "#/$defs/node" } },
    $defs: { node: { $ref: "#/$defs/node" } },
  };
  assert.doesNotThrow(() => validateSchemaDocument(recursive));
  assert.ok(codes(validateSchemaDocument(recursive)).includes("SCHEMA_REF_CYCLE"));

  const objectCycle = { type: "object" };
  objectCycle.properties = { self: objectCycle };
  assert.doesNotThrow(() => validateSchemaDocument(objectCycle));
  assert.ok(codes(validateSchemaDocument(objectCycle)).includes("SCHEMA_OBJECT_CYCLE"));

  assert.ok(codes(validateSchemaDocument({
    type: "object",
    unevaluatedProperties: false,
  })).includes("SCHEMA_KEYWORD_UNSUPPORTED"));
  assert.ok(codes(validateSchemaDocument({
    $ref: "#/$defs/value",
    type: "string",
    $defs: { value: { type: "string" } },
  })).includes("SCHEMA_REF_SIBLING"));
});

test("schema version, required fields, and unknown fields fail closed", () => {
  const unsupported = clone(parsedValidLesson.metadata);
  unsupported.schemaVersion = 2;
  assert.deepEqual(
    codes(validateLessonDocument(lessonText(unsupported), lessonSchema).issues),
    ["SCHEMA_CONST"],
  );

  const missing = clone(parsedValidLesson.metadata);
  delete missing.title;
  assert.deepEqual(
    codes(validateLessonDocument(lessonText(missing), lessonSchema).issues),
    ["SCHEMA_REQUIRED"],
  );

  const unknown = clone(parsedValidLesson.metadata);
  unknown.silentTypo = true;
  assert.deepEqual(
    codes(validateLessonDocument(lessonText(unknown), lessonSchema).issues),
    ["SCHEMA_UNKNOWN_FIELD"],
  );
});

test("lesson identity, prerequisite, level, path, and section invariants reject unsafe drift", () => {
  const self = clone(parsedValidLesson.metadata);
  self.prerequisiteLessonIds = [self.id];
  assert.deepEqual(
    codes(validateLessonDocument(lessonText(self), lessonSchema).issues),
    ["PREREQUISITE_SELF"],
  );

  const curriculumSelf = clone(parsedValidLesson.metadata);
  curriculumSelf.prerequisiteCurriculumIds = [curriculumSelf.curriculumIds[0]];
  assert.deepEqual(
    codes(validateLessonDocument(lessonText(curriculumSelf), lessonSchema).issues),
    ["PREREQUISITE_CURRICULUM_SELF"],
  );

  const trailingWhitespace = clone(parsedValidLesson.metadata);
  trailingWhitespace.title = "Invalid trailing line break\n";
  assert.deepEqual(
    codes(validateLessonDocument(lessonText(trailingWhitespace), lessonSchema).issues),
    ["SCHEMA_PATTERN", "LESSON_TITLE_HEADING_MISMATCH"],
  );

  const reversed = clone(parsedValidLesson.metadata);
  reversed.level = { from: "expert", to: "foundation" };
  assert.deepEqual(
    codes(validateLessonDocument(lessonText(reversed), lessonSchema).issues),
    ["LESSON_LEVEL_RANGE"],
  );

  const drivePath = clone(parsedValidLesson.metadata);
  drivePath.labs[0].path = "C:/temp/unsafe";
  assert.deepEqual(
    codes(validateLessonDocument(lessonText(drivePath), lessonSchema).issues),
    ["SCHEMA_PATTERN"],
  );

  const noPublicAlias = clone(parsedValidLesson.metadata);
  noPublicAlias.aliases = ["schema-fixture"];
  assert.deepEqual(
    codes(validateLessonDocument(lessonText(noPublicAlias), lessonSchema).issues),
    ["LESSON_PUBLIC_ALIAS_MISSING"],
  );

  const unsafePath = clone(parsedValidLesson.metadata);
  unsafePath.labs[0].path = "C:\\temp\\unsafe";
  assert.deepEqual(
    codes(validateLessonDocument(lessonText(unsafePath), lessonSchema).issues),
    ["SCHEMA_PATTERN"],
  );

  const missingSection = parsedValidLesson.body.replace(
    "## Failure zoom",
    "### Failure zoom",
  );
  const commentedSection = parsedValidLesson.body.replace(
    "## Failure zoom",
    "<!--\n## Failure zoom\n-->",
  );
  assert.deepEqual(
    codes(validateLessonDocument(
      lessonText(parsedValidLesson.metadata, commentedSection),
      lessonSchema,
    ).issues),
    ["LESSON_RAW_HTML_UNSUPPORTED", "LESSON_HEADING_MISSING"],
  );

  assert.deepEqual(
    codes(validateLessonDocument(
      lessonText(parsedValidLesson.metadata, missingSection),
      lessonSchema,
    ).issues),
    ["LESSON_HEADING_MISSING"],
  );
});

test("lesson title H1 is unique, exact, and ignores fenced or commented lookalikes", () => {
  const titleHeading = `# ${parsedValidLesson.metadata.title}`;
  const withoutTitle = parsedValidLesson.body.replace(`${titleHeading}\n`, "");

  assert.deepEqual(
    codes(validateLessonDocument(
      lessonText(parsedValidLesson.metadata, withoutTitle), lessonSchema,
    ).issues),
    ["LESSON_TITLE_HEADING_MISSING"],
  );

  const duplicateTitle = parsedValidLesson.body.replace(
    titleHeading, `${titleHeading}\n\n${titleHeading}`,
  );
  assert.deepEqual(
    codes(validateLessonDocument(lessonText(parsedValidLesson.metadata, duplicateTitle),
      lessonSchema).issues),
    ["LESSON_TITLE_HEADING_DUPLICATE"],
  );

  const mismatchedTitle = parsedValidLesson.body.replace(titleHeading, "# Wrong lesson title");
  assert.deepEqual(
    codes(validateLessonDocument(lessonText(parsedValidLesson.metadata, mismatchedTitle),
      lessonSchema).issues),
    ["LESSON_TITLE_HEADING_MISMATCH"],
  );

  for (const pseudoTitle of [
    `~~~text\n${titleHeading}\n~~~`,
    `<!--\n${titleHeading}\n-->`,
  ]) {
    const pseudoCodes = codes(validateLessonDocument(
      lessonText(parsedValidLesson.metadata, `${pseudoTitle}\n${withoutTitle}`), lessonSchema,
    ).issues);
    assert.ok(pseudoCodes.includes("LESSON_TITLE_HEADING_MISSING"));
    assert.equal(pseudoCodes.includes("LESSON_TITLE_HEADING_DUPLICATE"), false);
    assert.equal(pseudoCodes.includes("LESSON_TITLE_HEADING_MISMATCH"), false);
  }
});

test("fenced literals cannot corrupt heading state and raw HTML cannot fake headings", () => {
  for (const fencedLiteral of [
    `\`\`\`text\n<!--\n\`\`\`\n${parsedValidLesson.body}`,
    `~~~~text\n## not a section\n~~~~\n${parsedValidLesson.body}`,
    `\`\`\`\`text\n## not a section\n\`\`\`\`\`\n${parsedValidLesson.body}`,
  ]) {
    assert.deepEqual(
      validateLessonDocument(
        lessonText(parsedValidLesson.metadata, fencedLiteral), lessonSchema,
      ).issues,
      [],
    );
  }

  for (const rawHtmlWrapped of [
    `<pre>\n${parsedValidLesson.body}\n</pre>`,
    `<x-fixture>\n${parsedValidLesson.body}\n</x-fixture>`,
    `<![CDATA[\n${parsedValidLesson.body}\n]]>`,
  ]) {
    assert.deepEqual(
      codes(validateLessonDocument(
        lessonText(parsedValidLesson.metadata, rawHtmlWrapped), lessonSchema,
      ).issues),
      ["LESSON_RAW_HTML_UNSUPPORTED"],
    );
  }

  const invalidBacktickFence = `\`\`\`not-a-fence\`
<script>alert(1)</script>
## What you see and first thought
Duplicate heading
\`\`\``;
  const invalidFenceCodes = codes(validateLessonDocument(
    lessonText(parsedValidLesson.metadata,
      `${invalidBacktickFence}\n${parsedValidLesson.body}`),
    lessonSchema,
  ).issues);
  assert.ok(invalidFenceCodes.includes("LESSON_RAW_HTML_UNSUPPORTED"));
  assert.ok(invalidFenceCodes.includes("LESSON_HEADING_MISSING"));

  const quotedAngle = `<xmp title=\">\">\n${parsedValidLesson.body}`;
  assert.ok(codes(validateLessonDocument(
    lessonText(parsedValidLesson.metadata, quotedAngle), lessonSchema,
  ).issues).includes("LESSON_RAW_HTML_UNSUPPORTED"));
});

test("structured lesson Markdown allows only inert destinations and no images", () => {
  const safeBody = parsedValidLesson.body.replace(
    "Start by naming the exact symptom and boundary.",
    "Read [storage](/book/linux/storage), [this section](#terms-before-commands), and [kernel docs](https://docs.kernel.org/).",
  );
  assert.equal(validateLessonDocument(
    lessonText(parsedValidLesson.metadata, safeBody), lessonSchema,
  ).issues.length, 0);

  for (const [markdown, expectedCode] of [
    ["[unsafe](javascript:alert%281%29)", "LESSON_MARKDOWN_DESTINATION_UNSAFE"],
    ["[protocol relative](//example.invalid/path)", "LESSON_MARKDOWN_DESTINATION_UNSAFE"],
    ["[relative file](../../../README.md)", "LESSON_MARKDOWN_DESTINATION_UNSAFE"],
    ["![remote image](https://example.invalid/image.png)", "LESSON_MARKDOWN_IMAGE_UNSUPPORTED"],
  ]) {
    const body = parsedValidLesson.body.replace(
      "Start by naming the exact symptom and boundary.", markdown,
    );
    assert.ok(codes(validateLessonDocument(
      lessonText(parsedValidLesson.metadata, body), lessonSchema,
    ).issues).includes(expectedCode));
  }
});

test("required headings without teaching content are rejected", () => {
  const headingsOnly = [
    "# Empty lesson fixture",
    ...[
      "What you see and first thought", "Terms before commands", "Architecture map",
      "Request or state path", "Failure zoom", "Internals and state ownership",
      "Evidence table", "Command decoders", "Decision path", "Guided Ubuntu lab",
      "Production transfer", "Reliability, security, observability, capacity, and cost",
      "Traps and prevention", "Memory card and retrieval", "Complete answers",
      "Product-company interview", "Independent transfer and rubric", "References and review",
    ].map((heading) => `## ${heading}`),
  ].join("\n\n");
  const issues = validateLessonDocument(
    lessonText(parsedValidLesson.metadata, headingsOnly), lessonSchema).issues;
  assert.equal(issues.filter((entry) => entry.code === "LESSON_SECTION_EMPTY").length, 18);
});


test("mutating commands require cleanup and artifact IDs belong to the lesson", () => {
  const noCleanup = clone(parsedValidLesson.metadata);
  noCleanup.commands[0].risk = "mutating-bounded";
  assert.deepEqual(
    codes(validateLessonDocument(lessonText(noCleanup), lessonSchema).issues),
    ["MUTATING_COMMAND_CLEANUP"],
  );

  const disguisedMutation = clone(parsedValidLesson.metadata);
  disguisedMutation.commands[0].command = "sudo rm -rf -- /tmp/example";
  assert.deepEqual(
    codes(validateLessonDocument(lessonText(disguisedMutation), lessonSchema).issues),
    ["READ_ONLY_COMMAND_MUTATION_HINT"],
  );

  const wrongChild = clone(parsedValidLesson.metadata);
  wrongChild.commands[0].id = "LES-9002-CMD-001";
  assert.deepEqual(
    codes(validateLessonDocument(lessonText(wrongChild), lessonSchema).issues),
    ["CHILD_ID_MISMATCH"],
  );

  const duplicateChild = clone(parsedValidLesson.metadata);
  duplicateChild.labs[0].id = duplicateChild.commands[0].id;
  assert.deepEqual(
    codes(validateLessonDocument(lessonText(duplicateChild), lessonSchema).issues),
    [
      "CHILD_ID_MISMATCH",
      "DUPLICATE_CHILD_ID",
    ],
  );
});

test("bare command -v dependency inspection cannot hide a later mutation", () => {
  const dependencyInspection = clone(parsedValidLesson.metadata);
  dependencyInspection.commands[0].command =
    "command -v bash basename cat chmod cmp dirname find id install mktemp python3 realpath rmdir rm stat";
  assert.deepEqual(
    validateLessonDocument(lessonText(dependencyInspection), lessonSchema).issues,
    [],
  );

  const appendedMutation = clone(dependencyInspection);
  appendedMutation.commands[0].command += "; rm -f -- /tmp/unsafe-fixture";
  assert.deepEqual(
    codes(validateLessonDocument(lessonText(appendedMutation), lessonSchema).issues),
    ["READ_ONLY_COMMAND_MUTATION_HINT"],
  );
});

test("assessment answers and rubric totals are mandatory and internally consistent", () => {
  const missingAnswer = jsonFixture("valid", "assessment.json.fixture");
  delete missingAnswer.directAnswer;
  assert.deepEqual(
    codes(validateAssessmentRecord(missingAnswer, assessmentSchema)),
    ["ASSESSMENT_ANSWER_FIELD_MISSING"],
  );

  const independent = jsonFixture("valid", "assessment.json.fixture");
  independent.type = "independent-transfer";
  for (const field of [
    "directAnswer", "foundation", "reasoningSteps", "seniorAnswer", "weakAnswer",
    "whyWeak", "evidence", "followUps",
  ]) delete independent[field];
  independent.deliverables = ["A diagnosis and safe remediation plan"];
  independent.evidenceRequirements = ["Sanitized learner-operated command output"];
  independent.reviewPolicy = "reviewer-only-no-model-answer";
  assert.deepEqual(validateAssessmentRecord(independent, assessmentSchema), []);

  const leakedAnswer = clone(independent);
  leakedAnswer.directAnswer = "This answer must remain isolated from the learner attempt.";
  assert.deepEqual(
    codes(validateAssessmentRecord(leakedAnswer, assessmentSchema)),
    ["INDEPENDENT_TRANSFER_ANSWER_LEAK"],
  );

  const incompleteTransfer = clone(independent);
  delete incompleteTransfer.evidenceRequirements;
  assert.deepEqual(
    codes(validateAssessmentRecord(incompleteTransfer, assessmentSchema)),
    ["INDEPENDENT_TRANSFER_FIELD_MISSING"],
  );

  const inconsistent = jsonFixture("invalid", "assessment-rubric-total.json.fixture");
  assert.deepEqual(
    codes(validateAssessmentRecord(inconsistent, assessmentSchema)),
    ["RUBRIC_SCORE_MISMATCH"],
  );
});

test("references reject credential-bearing URLs and invalid review windows", () => {
  const credentialBearing = jsonFixture(
    "invalid",
    "reference-credentials.json.fixture",
  );
  assert.deepEqual(
    codes(validateReferenceRecord(credentialBearing, referenceSchema)),
    ["REFERENCE_URL_CREDENTIALS"],
  );

  const staleWindow = jsonFixture("valid", "reference.json.fixture");
  staleWindow.reviewAfter = staleWindow.lastReviewed;
  assert.deepEqual(
    codes(validateReferenceRecord(staleWindow, referenceSchema)),
    ["REVIEW_WINDOW_INVALID"],
  );

  const impossibleDate = jsonFixture("valid", "reference.json.fixture");
  impossibleDate.lastReviewed = "2026-02-31";
  assert.deepEqual(
    codes(validateReferenceRecord(impossibleDate, referenceSchema)),
    ["SCHEMA_DATE"],
  );

  const signed = jsonFixture("valid", "reference.json.fixture");
  signed.url = "https://example.com/reference?token=not-logged#credential=not-logged";
  assert.deepEqual(
    codes(validateReferenceRecord(signed, referenceSchema)),
    ["REFERENCE_URL_QUERY_FORBIDDEN", "REFERENCE_URL_FRAGMENT_FORBIDDEN"],
  );

  for (const unsafeUrl of [
    "https://example.com/docs\n",
    "https://example.com/docs ",
    "https://exam\tple.com/docs",
  ]) {
    const hiddenNormalization = jsonFixture("valid", "reference.json.fixture");
    hiddenNormalization.url = unsafeUrl;
    assert.ok(codes(validateReferenceRecord(
      hiddenNormalization, referenceSchema,
    )).includes("REFERENCE_URL_RAW_WHITESPACE"));
  }

  const nonCanonical = jsonFixture("valid", "reference.json.fixture");
  nonCanonical.url = "https://EXAMPLE.com";
  assert.ok(codes(validateReferenceRecord(
    nonCanonical, referenceSchema,
  )).includes("REFERENCE_URL_NORMALIZATION_DRIFT"));
});

test("curriculum IDs come only from canonical matrix tables", () => {
  const fakeRow = "| FAKE-999 | 1 | fake | none | fake | fake | fake | fake | fake | fake | fake |";
  const text = [
    `<!-- hidden -->${fakeRow}`,
    "<pre>",
    "| ID | Req. | Domain | Prerequisites | Chapters | Labs | Incidents | Capstone | Status | Gaps | Evidence |",
    "|---|---:|---|---|---|---|---|---|---|---|---|",
    fakeRow,
    "</pre>",
    "<x-fixture>",
    "| ID | Req. | Domain | Prerequisites | Chapters | Labs | Incidents | Capstone | Status | Gaps | Evidence |",
    "|---|---:|---|---|---|---|---|---|---|---|---|",
    fakeRow,
    "</x-fixture>",
    "",
    fakeRow,
    fixtureMatrix(),
  ].join("\n");
  const collected = collectCurriculumIdsFromMarkdown(text);
  assert.deepEqual([...collected].sort(), [...matrixIds].sort());
  assert.equal(collected.has("FAKE-999"), false);
});

test("schema v1 refuses self-awarded verified chapter status", () => {
  const unproved = clone(parsedValidLesson.metadata);
  unproved.contentStatus = "verified-chapter";
  assert.deepEqual(
    codes(validateLessonDocument(lessonText(unproved), lessonSchema).issues),
    ["SCHEMA_ENUM"],
  );
});

test("lesson aliases are limited to public aliases or lowercase slug aliases", () => {
  const unsafeAlias = clone(parsedValidLesson.metadata);
  unsafeAlias.aliases.push("https://example.com/not-an-alias");
  assert.ok(codes(validateLessonDocument(
    lessonText(unsafeAlias), lessonSchema,
  ).issues).includes("SCHEMA_PATTERN"));
});

test("diagnostic ordering is deterministic across repeated validation", () => {
  const broken = clone(parsedValidLesson.metadata);
  delete broken.title;
  broken.unknownField = "rejected";
  broken.lastReviewed = "not-a-date";
  const first = validateLessonDocument(lessonText(broken), lessonSchema).issues;
  const second = validateLessonDocument(lessonText(broken), lessonSchema).issues;
  assert.deepEqual(second, first);
  assert.deepEqual(codes(first), [
    "SCHEMA_REQUIRED",
    "SCHEMA_DATE",
    "SCHEMA_UNKNOWN_FIELD",
  ]);
});

test("production repository scan executes all three schemas and ignores fixture suffixes", () => {
  const result = validateRepositoryStructuredContent(repositoryRoot);
  assert.deepEqual(result.issues, []);
  assert.equal(result.metrics.schemaFiles, 3);
  assert.equal(result.metrics.legacyLessons, 5);
});

test("a disposable repository proves valid cross-record relationships", () => {
  const result = validateFixtureRepository({ twoLessons: true });
  assert.deepEqual(result.issues, []);
  assert.deepEqual(result.metrics, {
    schemaFiles: 3,
    lessons: 2,
    assessments: 2,
    references: 2,
    legacyLessons: 5,
  });
});

test("repository order and route identity are volume-aware", () => {
  const crossVolume = validateFixtureRepository({
    twoLessons: true,
    mutate(model) {
      model.lessons[1].volume = "00-start-safely";
      model.lessons[1].curriculumIds = ["FND-001"];
      model.lessons[1].order = model.lessons[0].order;
      model.lessons[1].route = "/book/start/schema-fixture-two";
    },
  });
  assert.deepEqual(crossVolume.issues, [],
    "the same local order must remain valid in different volumes");

  const sameVolume = validateFixtureRepository({
    twoLessons: true,
    mutate(model) {
      model.lessons[1].order = model.lessons[0].order;
    },
  });
  assert.ok(codes(sameVolume.issues).includes("DUPLICATE_LESSON_ORDER"));

  const startVolume = validateFixtureRepository({
    mutate(model) {
      model.lessons[0].volume = "00-start-safely";
      model.lessons[0].curriculumIds = ["FND-001"];
      model.lessons[0].prerequisiteCurriculumIds = [];
      model.lessons[0].route = "/book/start/schema-fixture";
    },
  });
  assert.deepEqual(startVolume.issues, [],
    "Volume 00 must use the public start route segment");

  const wrongStartSegment = validateFixtureRepository({
    mutate(model) {
      model.lessons[0].volume = "00-start-safely";
      model.lessons[0].curriculumIds = ["FND-001"];
      model.lessons[0].prerequisiteCurriculumIds = [];
    },
  });
  assert.ok(codes(wrongStartSegment.issues).includes("LESSON_ROUTE_IDENTITY_MISMATCH"));

  const wrongCurriculumHome = validateFixtureRepository({
    mutate(model) {
      model.lessons[0].volume = "00-start-safely";
      model.lessons[0].route = "/book/start/schema-fixture";
    },
  });
  assert.ok(codes(wrongCurriculumHome.issues).includes("CURRICULUM_VOLUME_HOME_MISMATCH"),
    "a structured lesson cannot claim a curriculum ID from another canonical volume");
});

test("repository validation rejects identity collisions and legacy reuse", () => {
  const collisions = validateFixtureRepository({
    twoLessons: true,
    mutate(model) {
      model.lessons[1].route = model.lessons[0].route;
      model.lessons[1].aliases[1] = model.lessons[0].aliases[0];
    },
  });
  assert.ok(codes(collisions.issues).includes("DUPLICATE_LESSON_ROUTE"));
  assert.ok(codes(collisions.issues).includes("DUPLICATE_LESSON_ALIAS"));

  const legacyRoute = validateFixtureRepository({
    mutate(model) {
      model.lessons[0].route = "/book/linux/storage";
    },
  });
  assert.ok(codes(legacyRoute.issues).includes("DUPLICATE_LESSON_ROUTE"));

  const structuredCurriculumCollision = validateFixtureRepository({
    twoLessons: true,
    mutate(model) {
      model.lessons[1].curriculumIds = [...model.lessons[0].curriculumIds];
      model.lessons[1].prerequisiteCurriculumIds = [];
    },
  });
  assert.ok(codes(structuredCurriculumCollision.issues).includes("DUPLICATE_CURRICULUM_OWNER"));

  const legacyCurriculumCollision = validateFixtureRepository({
    mutate(model) {
      model.lessons[0].volume = "02-connectivity";
      model.lessons[0].route = "/book/connectivity/schema-fixture";
      model.lessons[0].curriculumIds = ["NET-003"];
      model.lessons[0].prerequisiteCurriculumIds = [];
    },
  });
  assert.ok(codes(legacyCurriculumCollision.issues).includes("DUPLICATE_CURRICULUM_OWNER"),
    "structured ownership cannot overlap a published legacy curriculum owner");

  const legacyId = validateFixtureRepository({
    mutate(model) {
      const replacements = [
        ["LES-9001", "LES-0001"], ["ASM-9001", "ASM-0001"], ["REF-9001", "REF-0001"],
      ];
      model.lessons[0] = replaceIds(model.lessons[0], replacements);
      model.lessons[0].prerequisiteLessonIds = ["LES-0002"];
      model.assessments[0] = replaceIds(model.assessments[0], replacements);
      model.references[0] = replaceIds(model.references[0], replacements);
    },
  });
  assert.ok(codes(legacyId.issues).includes("LEGACY_MIGRATION_IDENTITY_DRIFT"));
});

test("a structured migration may preserve an exact legacy identity", () => {
  const result = validateFixtureRepository({
    mutate(model) {
      const replacements = [
        ["LES-9001", "LES-0001"], ["ASM-9001", "ASM-0001"], ["REF-9001", "REF-0001"],
      ];
      const identity = model.legacyMap.lessons[0];
      model.lessons[0] = replaceIds(model.lessons[0], replacements);
      model.lessons[0].aliases = [...identity.aliases];
      model.lessons[0].curriculumIds = [...identity.curriculumIds];
      model.lessons[0].slug = identity.slug;
      model.lessons[0].route = identity.route;
      model.lessons[0].volume = "01-linux-systems";
      model.lessons[0].order = 1;
      model.lessons[0].prerequisiteLessonIds = ["LES-0002"];
      model.assessments[0] = replaceIds(model.assessments[0], replacements);
      model.references[0] = replaceIds(model.references[0], replacements);
    },
  });
  assert.deepEqual(result.issues, []);
});

test("only exact LES-0004 legacy identity keeps its published Volume 01 home", () => {
  const exactMigration = validateFixtureRepository({
    mutate(model) {
      const replacements = [
        ["LES-9001", "LES-0004"], ["ASM-9001", "ASM-0001"],
        ["REF-9001", "REF-0001"],
      ];
      const identity = model.legacyMap.lessons.find(({ id }) => id === "LES-0004");
      model.lessons[0] = replaceIds(model.lessons[0], replacements);
      model.lessons[0].aliases = [...identity.aliases];
      model.lessons[0].curriculumIds = [...identity.curriculumIds];
      model.lessons[0].slug = identity.slug;
      model.lessons[0].route = identity.route;
      model.lessons[0].volume = "01-linux-systems";
      model.lessons[0].order = 4;
      model.lessons[0].prerequisiteLessonIds = ["LES-0002"];
      model.lessons[0].prerequisiteCurriculumIds = ["LNX-002"];
      model.assessments[0] = replaceIds(model.assessments[0], replacements);
      model.references[0] = replaceIds(model.references[0], replacements);
    },
  });
  assert.deepEqual(exactMigration.issues, []);

  const driftedMigration = validateFixtureRepository({
    mutate(model) {
      const replacements = [
        ["LES-9001", "LES-0004"], ["ASM-9001", "ASM-0001"],
        ["REF-9001", "REF-0001"],
      ];
      const identity = model.legacyMap.lessons.find(({ id }) => id === "LES-0004");
      model.lessons[0] = replaceIds(model.lessons[0], replacements);
      model.lessons[0].aliases = [...identity.aliases];
      model.lessons[0].curriculumIds = [...identity.curriculumIds];
      model.lessons[0].slug = "network-request-path-changed";
      model.lessons[0].route = "/book/linux/network-request-path-changed";
      model.lessons[0].volume = "01-linux-systems";
      model.lessons[0].order = 4;
      model.lessons[0].prerequisiteLessonIds = ["LES-0002"];
      model.lessons[0].prerequisiteCurriculumIds = ["LNX-002"];
      model.assessments[0] = replaceIds(model.assessments[0], replacements);
      model.references[0] = replaceIds(model.references[0], replacements);
    },
  });
  assert.ok(codes(driftedMigration.issues).includes("LEGACY_MIGRATION_IDENTITY_DRIFT"));
  assert.ok(codes(driftedMigration.issues).includes("CURRICULUM_VOLUME_HOME_MISMATCH"));
});

test("published legacy reservations cannot be deleted from the map", () => {
  const result = validateFixtureRepository({
    mutate(model) {
      model.legacyMap.lessons = model.legacyMap.lessons.slice(1);
    },
  });
  assert.ok(codes(result.issues).includes("LEGACY_REQUIRED_RESERVATION_MISSING"));
});

test("every published legacy identity field is pinned independently", () => {
  for (const mutateIdentity of [
    (entry) => { entry.route = "/book/linux/changed-route"; },
    (entry) => { entry.slug = "changed-slug"; },
    (entry) => { entry.aliases = ["V01-L99", "changed-alias"]; },
    (entry) => { entry.curriculumIds = ["LNX-005"]; },
  ]) {
    const result = validateFixtureRepository({
      mutate(model) { mutateIdentity(model.legacyMap.lessons[0]); },
    });
    assert.ok(codes(result.issues).includes("LEGACY_IDENTITY_BASELINE_DRIFT"));
  }
});

test("repository loading rejects policy-valid schema weakening", () => {
  const root = createFixtureRepository();
  try {
    const schemaPath = join(root, "book", "schema", "lesson.schema.json");
    const weakened = JSON.parse(readFileSync(schemaPath, "utf8"));
    weakened.required = weakened.required.filter((field) => field !== "labs");
    writeFileSync(schemaPath, `${JSON.stringify(weakened, null, 2)}\n`);
    const result = validateRepositoryStructuredContent(root);
    assert.ok(codes(result.issues).includes("SCHEMA_BASELINE_DRIFT"));
    assert.equal(result.metrics.schemaFiles, 2);
  } finally {
    rmSync(root, { recursive: true, force: true });
  }
});

test("repository validation rejects ownership, dangling links, and cycles", () => {
  const wrongOwner = validateFixtureRepository({
    twoLessons: true,
    mutate(model) {
      model.assessments[0].lessonId = "LES-9002";
    },
  });
  assert.ok(codes(wrongOwner.issues).includes("ASSESSMENT_OWNER_MISMATCH"));

  const dangling = validateFixtureRepository({
    mutate(model) {
      model.lessons[0].referenceIds = ["REF-9999"];
    },
  });
  assert.ok(codes(dangling.issues).includes("REFERENCE_UNRESOLVED"));
  assert.ok(codes(dangling.issues).includes("REFERENCE_LESSON_BACKLINK_MISSING"));

  const cycle = validateFixtureRepository({
    twoLessons: true,
    mutate(model) {
      model.lessons[0].prerequisiteLessonIds = ["LES-9002"];
    },
  });
  assert.ok(codes(cycle.issues).includes("PREREQUISITE_CYCLE"));

  const wrongDomain = validateFixtureRepository({
    mutate(model) {
      model.lessons[0].domain = "network";
    },
  });
  assert.ok(codes(wrongDomain.issues).includes("ASSESSMENT_DOMAIN_MISMATCH"));
});

test("repository validation constrains lab and legacy source paths", () => {
  const labScope = validateFixtureRepository({
    mutate(model) {
      model.lessons[0].labs[0].path = ".";
    },
  });
  assert.ok(codes(labScope.issues).includes("LAB_PATH_SCOPE"));

  const gitMetadata = validateFixtureRepository({
    mutate(model) {
      model.lessons[0].labs[0].path = "labs/.GiT";
    },
  });
  assert.ok(codes(gitMetadata.issues).includes("LAB_PATH_SCOPE"));

  const missingLegacySource = validateFixtureRepository({
    mutate(model) {
      model.legacyMap.lessons[0].sources[0] = "learning-cockpit/app/missing-source.ts";
    },
  });
  assert.ok(codes(missingLegacySource.issues).includes("LEGACY_SOURCE_MISSING"));
});

function createDirectoryLinkOrSkip(t, target, linkPath) {
  try {
    symlinkSync(target, linkPath, process.platform === "win32" ? "junction" : "dir");
    return true;
  } catch (error) {
    if (["EPERM", "EACCES", "ENOSYS"].includes(error?.code)) {
      t.skip(`directory links are unavailable in this environment: ${error.code}`);
      return false;
    }
    throw error;
  }
}

function createFileLinkOrSkip(t, target, linkPath) {
  try {
    symlinkSync(target, linkPath, "file");
    return true;
  } catch (error) {
    if (["EPERM", "EACCES", "ENOSYS"].includes(error?.code)) {
      t.skip(`file links are unavailable in this environment: ${error.code}`);
      return false;
    }
    throw error;
  }
}

test("canonical content trees reject symlinks and junctions", (t) => {
  const root = createFixtureRepository();
  try {
    const target = join(root, "book", "volumes", parsedValidLesson.metadata.volume);
    const linkPath = join(root, "book", "volumes", "linked-volume");
    if (!createDirectoryLinkOrSkip(t, target, linkPath)) return;
    const result = validateRepositoryStructuredContent(root);
    assert.ok(codes(result.issues).includes("CONTENT_SYMLINK_UNSUPPORTED"));
  } finally {
    rmSync(root, { recursive: true, force: true });
  }
});

test("canonical book ancestors cannot be symlinks or junctions", (t) => {
  const root = createFixtureRepository();
  try {
    const bookPath = join(root, "book");
    const actualBookPath = join(root, "actual-book");
    renameSync(bookPath, actualBookPath);
    if (!createDirectoryLinkOrSkip(t, actualBookPath, bookPath)) return;
    const result = validateRepositoryStructuredContent(root);
    assert.ok(codes(result.issues).includes("CONTENT_SYMLINK_UNSUPPORTED"));
  } finally {
    rmSync(root, { recursive: true, force: true });
  }
});

test("canonical content roots preserve exact case across operating systems", () => {
  const root = createFixtureRepository();
  try {
    const lower = join(root, "book", "volumes");
    const intermediate = join(root, "volumes-case-change");
    const upper = join(root, "book", "Volumes");
    renameSync(lower, intermediate);
    renameSync(intermediate, upper);
    const result = validateRepositoryStructuredContent(root);
    assert.ok(codes(result.issues).includes("CANONICAL_PATH_CASE_MISMATCH"));
  } finally {
    rmSync(root, { recursive: true, force: true });
  }
});

test("dangling canonical-root links fail closed", (t) => {
  const root = createFixtureRepository();
  try {
    const volumesPath = join(root, "book", "volumes");
    const temporaryTarget = join(root, "temporary-volumes-target");
    renameSync(volumesPath, temporaryTarget);
    if (!createDirectoryLinkOrSkip(t, temporaryTarget, volumesPath)) return;
    rmSync(temporaryTarget, { recursive: true, force: true });
    const result = validateRepositoryStructuredContent(root);
    assert.ok(codes(result.issues).includes("CONTENT_SYMLINK_UNSUPPORTED"));
  } finally {
    rmSync(root, { recursive: true, force: true });
  }
});

test("canonical schema and map filenames preserve exact case", () => {
  const root = createFixtureRepository();
  try {
    const schemaRoot = join(root, "book", "schema");
    for (const [canonicalName, changedName] of [
      ["lesson.schema.json", "Lesson.schema.json"],
      ["legacy-content-map.json", "Legacy-content-map.json"],
    ]) {
      const canonical = join(schemaRoot, canonicalName);
      const intermediate = join(root, `${canonicalName}.case-change`);
      const changed = join(schemaRoot, changedName);
      renameSync(canonical, intermediate);
      renameSync(intermediate, changed);
    }
    const result = validateRepositoryStructuredContent(root);
    assert.ok(codes(result.issues)
      .filter((code) => code === "CANONICAL_FILE_CASE_MISMATCH").length >= 2);
  } finally {
    rmSync(root, { recursive: true, force: true });
  }
});

test("schema and legacy-map policy files cannot be symlinks", (t) => {
  const root = createFixtureRepository();
  try {
    const schemaRoot = join(root, "book", "schema");
    for (const canonicalName of ["lesson.schema.json", "legacy-content-map.json"]) {
      const canonical = join(schemaRoot, canonicalName);
      const target = join(root, `${canonicalName}.external-target`);
      renameSync(canonical, target);
      if (!createFileLinkOrSkip(t, target, canonical)) return;
    }
    const result = validateRepositoryStructuredContent(root);
    assert.ok(codes(result.issues)
      .filter((code) => code === "CANONICAL_POLICY_FILE_SYMLINK").length >= 2);
    assert.equal(result.metrics.schemaFiles, 2);
    assert.equal(result.metrics.legacyLessons, 0);
  } finally {
    rmSync(root, { recursive: true, force: true });
  }
});

test("lab links cannot escape their selected allowed root", (t) => {
  const root = createFixtureRepository();
  try {
    const lessonDirectory = join(root, "book", "volumes", parsedValidLesson.metadata.volume,
      `${parsedValidLesson.metadata.id}-${parsedValidLesson.metadata.slug}`);
    const lessonPath = join(lessonDirectory, "lesson.md");
    const parsed = parseJsonFrontMatter(readFileSync(lessonPath, "utf8"));
    parsed.metadata.labs[0].path = "labs/escaped";
    writeFileSync(lessonPath, lessonText(parsed.metadata, parsed.body));

    const labsRoot = join(root, "labs");
    mkdirSync(labsRoot);
    const outsideTarget = join(root, "learning-cockpit");
    const escaped = join(labsRoot, "escaped");
    if (!createDirectoryLinkOrSkip(t, outsideTarget, escaped)) return;

    const result = validateRepositoryStructuredContent(root);
    assert.ok(codes(result.issues).includes("LAB_PATH_ALLOWED_ROOT_ESCAPE"));
  } finally {
    rmSync(root, { recursive: true, force: true });
  }
});

test("record filenames are bound to their canonical IDs", () => {
  const root = createFixtureRepository();
  try {
    const correct = join(root, "book", "assessments", "linux", "ASM-9001.json");
    const wrong = join(root, "book", "assessments", "linux", "wrong-name.json");
    writeFileSync(wrong, readFileSync(correct, "utf8"));
    rmSync(correct);
    const result = validateRepositoryStructuredContent(root);
    assert.ok(codes(result.issues).includes("ASSESSMENT_FILENAME_MISMATCH"));
  } finally {
    rmSync(root, { recursive: true, force: true });
  }
});

test("lesson files use the exact canonical path and lowercase filename", () => {
  const root = createFixtureRepository();
  try {
    const lessonDirectory = join(root, "book", "volumes", parsedValidLesson.metadata.volume,
      `${parsedValidLesson.metadata.id}-${parsedValidLesson.metadata.slug}`);
    const correct = join(lessonDirectory, "lesson.md");
    const nested = join(lessonDirectory, "nested");
    mkdirSync(nested);
    writeFileSync(join(nested, "Lesson.MD"), readFileSync(correct, "utf8"));
    rmSync(correct);
    const result = validateRepositoryStructuredContent(root);
    assert.ok(codes(result.issues).includes("LESSON_PATH_INVALID"));
  } finally {
    rmSync(root, { recursive: true, force: true });
  }
});

test("repository loading rejects a weakened schema even with no usable lesson schema", () => {
  const root = createFixtureRepository();
  try {
    const schemaPath = join(root, "book", "schema", "lesson.schema.json");
    const weakened = JSON.parse(readFileSync(schemaPath, "utf8"));
    weakened.silentUnsupportedKeyword = true;
    writeFileSync(schemaPath, `${JSON.stringify(weakened, null, 2)}\n`);
    const result = validateRepositoryStructuredContent(root);
    assert.ok(codes(result.issues).includes("SCHEMA_KEYWORD_UNSUPPORTED"));
    assert.equal(result.metrics.schemaFiles, 2);
  } finally {
    rmSync(root, { recursive: true, force: true });
  }
});

test("the live structured corpus publishes thirty-six lessons with exact ownership and answer isolation", () => {
  const result = validateRepositoryStructuredContent(repositoryRoot);
  assert.deepEqual(result.issues, []);
  assert.equal(result.metrics.lessons, 36);
  assert.equal(result.metrics.assessments, 108);
  assert.equal(result.metrics.references, 345);

  const expectations = [
    {
      path: join(repositoryRoot, "book", "volumes", "01-linux-systems",
        "LES-0001-storage", "lesson.md"),
      id: "LES-0001",
      domain: "linux",
      route: "/book/linux/storage",
      volume: "01-linux-systems",
      order: 1,
      prerequisiteLessonIds: [],
      prerequisiteCurriculumIds: ["FND-001", "DBG-001"],
      assessmentIds: ["ASM-0271", "ASM-0272", "ASM-0273"],
      referenceIds: [
        "REF-1215", "REF-1216", "REF-1217",
        "REF-1218", "REF-1219", "REF-1220",
      ],
      independentId: "ASM-0273",
    },
    {
      path: join(repositoryRoot, "book", "volumes", "01-linux-systems",
        "LES-0002-processes-signals-systemd", "lesson.md"),
      id: "LES-0002",
      domain: "linux",
      route: "/book/linux/processes-signals-systemd",
      volume: "01-linux-systems",
      order: 2,
      prerequisiteLessonIds: ["LES-0001"],
      prerequisiteCurriculumIds: ["LNX-001"],
      assessmentIds: ["ASM-0262", "ASM-0263", "ASM-0264"],
      referenceIds: ["REF-1200", "REF-1201", "REF-1202"],
      independentId: "ASM-0264",
    },
    {
      path: join(repositoryRoot, "book", "volumes", "01-linux-systems",
        "LES-0003-cpu-memory-pressure", "lesson.md"),
      id: "LES-0003",
      domain: "linux",
      route: "/book/linux/cpu-memory-pressure",
      volume: "01-linux-systems",
      order: 3,
      prerequisiteLessonIds: ["LES-0002"],
      prerequisiteCurriculumIds: ["LNX-002"],
      assessmentIds: ["ASM-0265", "ASM-0266", "ASM-0267"],
      referenceIds: [
        "REF-1203", "REF-1204", "REF-1205",
        "REF-1206", "REF-1207", "REF-1208",
      ],
      independentId: "ASM-0267",
    },
    {
      path: join(repositoryRoot, "book", "volumes", "01-linux-systems",
        "LES-0005-identity-permissions", "lesson.md"),
      id: "LES-0005",
      domain: "linux",
      route: "/book/linux/identity-permissions",
      volume: "01-linux-systems",
      order: 5,
      prerequisiteLessonIds: ["LES-0002"],
      prerequisiteCurriculumIds: ["LNX-002"],
      assessmentIds: ["ASM-0268", "ASM-0269", "ASM-0270"],
      referenceIds: [
        "REF-1209", "REF-1210", "REF-1211",
        "REF-1212", "REF-1213", "REF-1214",
      ],
      independentId: "ASM-0270",
    },
    {
      path: join(repositoryRoot, "book", "volumes", "01-linux-systems",
        "LES-0004-network-request-path", "lesson.md"),
      id: "LES-0004",
      domain: "connectivity",
      route: "/book/linux/network-request-path",
      volume: "01-linux-systems",
      order: 4,
      prerequisiteLessonIds: ["LES-0002"],
      prerequisiteCurriculumIds: ["LNX-002", "FND-001", "DBG-001"],
      assessmentIds: ["ASM-0274", "ASM-0275", "ASM-0276"],
      referenceIds: [
        "REF-1221", "REF-1222", "REF-1223",
        "REF-1224", "REF-1225", "REF-1226",
      ],
      independentId: "ASM-0276",
    },
    {
      path: join(repositoryRoot, "book", "volumes", "00-start-safely",
        "LES-0007-systems-thinking", "lesson.md"),
      id: "LES-0007",
      domain: "foundations",
      route: "/book/start/systems-thinking",
      volume: "00-start-safely",
      order: 1,
      prerequisiteLessonIds: [],
      prerequisiteCurriculumIds: [],
      assessmentIds: ["ASM-0004", "ASM-0005", "ASM-0006"],
      referenceIds: [
        "REF-0009", "REF-0010", "REF-0011", "REF-0012",
        "REF-0013", "REF-0014", "REF-0015", "REF-0016",
      ],
      independentId: "ASM-0006",
    },
    {
      path: join(repositoryRoot, "book", "volumes", "00-start-safely",
        "LES-0008-evidence-driven-troubleshooting", "lesson.md"),
      id: "LES-0008",
      domain: "foundations",
      route: "/book/start/evidence-driven-troubleshooting",
      volume: "00-start-safely",
      order: 2,
      prerequisiteLessonIds: ["LES-0007"],
      prerequisiteCurriculumIds: ["FND-001"],
      assessmentIds: ["ASM-0007", "ASM-0008", "ASM-0009"],
      referenceIds: [
        "REF-0017", "REF-0018", "REF-0019", "REF-0020",
        "REF-0021", "REF-0022", "REF-0023", "REF-0024",
      ],
      independentId: "ASM-0009",
    },
    {
      path: join(repositoryRoot, "book", "volumes", "03-engineering-delivery",
        "LES-0009-safe-local-workbench", "lesson.md"),
      id: "LES-0009",
      domain: "engineering",
      route: "/book/engineering/safe-local-workbench",
      volume: "03-engineering-delivery",
      order: 1,
      prerequisiteLessonIds: ["LES-0007", "LES-0008"],
      prerequisiteCurriculumIds: ["FND-001"],
      assessmentIds: ["ASM-0010", "ASM-0011", "ASM-0012"],
      referenceIds: [
        "REF-0025", "REF-0026", "REF-0027", "REF-0028",
        "REF-0029", "REF-0030", "REF-0031", "REF-0032",
      ],
      independentId: "ASM-0012",
    },
    {
      path: join(repositoryRoot, "book", "volumes", "01-linux-systems",
        "LES-0006-boot-kernel-systemd-journal", "lesson.md"),
      id: "LES-0006",
      domain: "linux",
      route: "/book/linux/boot-kernel-systemd-journal",
      volume: "01-linux-systems",
      order: 6,
      prerequisiteLessonIds: ["LES-0002"],
      prerequisiteCurriculumIds: ["LNX-002"],
      assessmentIds: ["ASM-0001", "ASM-0002", "ASM-0003"],
      referenceIds: [
        "REF-0001", "REF-0002", "REF-0003", "REF-0004",
        "REF-0005", "REF-0006", "REF-0007", "REF-0008",
      ],
      independentId: "ASM-0003",
    },
    {
      path: join(repositoryRoot, "book", "volumes", "01-linux-systems",
        "LES-0010-block-io-storage-performance", "lesson.md"),
      id: "LES-0010",
      domain: "linux",
      route: "/book/linux/block-io-storage-performance",
      volume: "01-linux-systems",
      order: 7,
      prerequisiteLessonIds: ["LES-0001", "LES-0003"],
      prerequisiteCurriculumIds: ["LNX-001", "LNX-003"],
      assessmentIds: ["ASM-0013", "ASM-0014", "ASM-0015"],
      referenceIds: [
        "REF-0033", "REF-0034", "REF-0035", "REF-0036",
        "REF-0037", "REF-0038", "REF-0039", "REF-0040",
      ],
      independentId: "ASM-0015",
    },
    {
      path: join(repositoryRoot, "book", "volumes", "01-linux-systems",
        "LES-0011-namespaces-cgroups-isolation", "lesson.md"),
      id: "LES-0011",
      domain: "linux",
      route: "/book/linux/namespaces-cgroups-isolation",
      volume: "01-linux-systems",
      order: 8,
      prerequisiteLessonIds: ["LES-0002", "LES-0003", "LES-0004", "LES-0005"],
      prerequisiteCurriculumIds: ["LNX-002", "LNX-003", "LNX-004", "NET-003"],
      assessmentIds: ["ASM-0016", "ASM-0017", "ASM-0018"],
      referenceIds: [
        "REF-0041", "REF-0042", "REF-0043", "REF-0044",
        "REF-0045", "REF-0046", "REF-0047", "REF-0048",
      ],
      independentId: "ASM-0018",
    },
    {
      path: join(repositoryRoot, "book", "volumes", "02-connectivity",
        "LES-0012-ethernet-ip-cidr-routing-nat", "lesson.md"),
      id: "LES-0012",
      domain: "connectivity",
      route: "/book/connectivity/ethernet-ip-cidr-routing-nat",
      volume: "02-connectivity",
      order: 1,
      prerequisiteLessonIds: ["LES-0007"],
      prerequisiteCurriculumIds: ["FND-001"],
      assessmentIds: ["ASM-0019", "ASM-0020", "ASM-0021"],
      referenceIds: [
        "REF-0049", "REF-0050", "REF-0051", "REF-0052",
        "REF-0053", "REF-0054", "REF-0055", "REF-0056",
      ],
      independentId: "ASM-0021",
    },
    {
      path: join(repositoryRoot, "book", "volumes", "02-connectivity",
        "LES-0013-tcp-udp-sockets-exhaustion", "lesson.md"),
      id: "LES-0013",
      domain: "connectivity",
      route: "/book/connectivity/tcp-udp-sockets-exhaustion",
      volume: "02-connectivity",
      order: 2,
      prerequisiteLessonIds: ["LES-0012", "LES-0004"],
      prerequisiteCurriculumIds: ["NET-001", "NET-002", "NET-003", "NET-004", "NET-005", "NET-006"],
      assessmentIds: ["ASM-0022", "ASM-0023", "ASM-0024"],
      referenceIds: [
        "REF-0057", "REF-0058", "REF-0059", "REF-0060",
        "REF-0061", "REF-0062", "REF-0063", "REF-0064",
      ],
      independentId: "ASM-0024",
    },
    {
      path: join(repositoryRoot, "book", "volumes", "02-connectivity",
        "LES-0014-dns-service-discovery", "lesson.md"),
      id: "LES-0014",
      domain: "connectivity",
      route: "/book/connectivity/dns-service-discovery",
      volume: "02-connectivity",
      order: 3,
      prerequisiteLessonIds: ["LES-0012", "LES-0013"],
      prerequisiteCurriculumIds: ["NET-001", "NET-002", "NET-003"],
      assessmentIds: ["ASM-0025", "ASM-0026", "ASM-0027"],
      referenceIds: [
        "REF-0065", "REF-0066", "REF-0067", "REF-0068",
        "REF-0069", "REF-0070", "REF-0071", "REF-0072",
      ],
      independentId: "ASM-0027",
    },
    {
      path: join(repositoryRoot, "book", "volumes", "02-connectivity",
        "LES-0015-http-proxies-load-balancing", "lesson.md"),
      id: "LES-0015",
      domain: "connectivity",
      route: "/book/connectivity/http-proxies-load-balancing",
      volume: "02-connectivity",
      order: 4,
      prerequisiteLessonIds: ["LES-0013", "LES-0014"],
      prerequisiteCurriculumIds: ["NET-003", "NET-004"],
      assessmentIds: ["ASM-0028", "ASM-0029", "ASM-0030"],
      referenceIds: [
        "REF-0073", "REF-0074", "REF-0075", "REF-0076",
        "REF-0077", "REF-0078", "REF-0079", "REF-0080",
      ],
      independentId: "ASM-0030",
    },
    {
      path: join(repositoryRoot, "book", "volumes", "02-connectivity",
        "LES-0016-tls-pki-mtls-rotation", "lesson.md"),
      id: "LES-0016",
      domain: "connectivity",
      route: "/book/connectivity/tls-pki-mtls-rotation",
      volume: "02-connectivity",
      order: 5,
      prerequisiteLessonIds: ["LES-0014", "LES-0015"],
      prerequisiteCurriculumIds: ["NET-004", "NET-005"],
      assessmentIds: ["ASM-0031", "ASM-0032", "ASM-0033"],
      referenceIds: [
        "REF-0081", "REF-0082", "REF-0083", "REF-0084",
        "REF-0085", "REF-0086", "REF-0087", "REF-0088",
      ],
      independentId: "ASM-0033",
    },
    {
      path: join(repositoryRoot, "book", "volumes", "03-engineering-delivery",
        "LES-0017-bash-safe-automation", "lesson.md"),
      id: "LES-0017",
      domain: "engineering",
      route: "/book/engineering/bash-safe-automation",
      volume: "03-engineering-delivery",
      order: 2,
      prerequisiteLessonIds: ["LES-0009", "LES-0002"],
      prerequisiteCurriculumIds: ["SCM-001", "LNX-002"],
      assessmentIds: ["ASM-0034", "ASM-0035", "ASM-0036"],
      referenceIds: [
        "REF-0089", "REF-0090", "REF-0091", "REF-0092",
        "REF-0093", "REF-0094", "REF-0095", "REF-0096",
      ],
      independentId: "ASM-0036",
    },
    {
      path: join(repositoryRoot, "book", "volumes", "03-engineering-delivery",
        "LES-0018-python-operational-automation", "lesson.md"),
      id: "LES-0018",
      domain: "engineering",
      route: "/book/engineering/python-operational-automation",
      volume: "03-engineering-delivery",
      order: 3,
      prerequisiteLessonIds: ["LES-0009", "LES-0017"],
      prerequisiteCurriculumIds: ["SCM-001", "AUT-001"],
      assessmentIds: ["ASM-0037", "ASM-0038", "ASM-0039"],
      referenceIds: [
        "REF-0097", "REF-0098", "REF-0099", "REF-0100",
        "REF-0101", "REF-0102", "REF-0103", "REF-0104",
      ],
      independentId: "ASM-0039",
    },
    {
      path: join(repositoryRoot, "book", "volumes", "03-engineering-delivery",
        "LES-0019-powershell-safe-automation", "lesson.md"),
      id: "LES-0019",
      domain: "engineering",
      route: "/book/engineering/powershell-safe-automation",
      volume: "03-engineering-delivery",
      order: 4,
      prerequisiteLessonIds: ["LES-0009", "LES-0017"],
      prerequisiteCurriculumIds: ["SCM-001", "AUT-001"],
      assessmentIds: ["ASM-0040", "ASM-0041", "ASM-0042"],
      referenceIds: [
        "REF-0105", "REF-0106", "REF-0107", "REF-0108",
        "REF-0109", "REF-0110", "REF-0111", "REF-0112",
      ],
      independentId: "ASM-0042",
    },
    {
      path: join(repositoryRoot, "book", "volumes", "03-engineering-delivery",
        "LES-0020-go-infrastructure-tooling", "lesson.md"),
      id: "LES-0020",
      domain: "engineering",
      route: "/book/engineering/go-infrastructure-tooling",
      volume: "03-engineering-delivery",
      order: 5,
      prerequisiteLessonIds: ["LES-0009", "LES-0018"],
      prerequisiteCurriculumIds: ["SCM-001", "AUT-002"],
      assessmentIds: ["ASM-0043", "ASM-0044", "ASM-0045"],
      referenceIds: [
        "REF-0113", "REF-0114", "REF-0115", "REF-0116",
        "REF-0117", "REF-0118", "REF-0119", "REF-0120",
      ],
      independentId: "ASM-0045",
    },
    {
      path: join(repositoryRoot, "book", "volumes", "03-engineering-delivery",
        "LES-0021-api-contracts-serialization", "lesson.md"),
      id: "LES-0021",
      domain: "engineering",
      route: "/book/engineering/api-contracts-serialization",
      volume: "03-engineering-delivery",
      order: 6,
      prerequisiteLessonIds: ["LES-0015", "LES-0018"],
      prerequisiteCurriculumIds: ["NET-005", "AUT-002"],
      assessmentIds: ["ASM-0046", "ASM-0047", "ASM-0048"],
      referenceIds: [
        "REF-0121", "REF-0122", "REF-0123", "REF-0124",
        "REF-0125", "REF-0126", "REF-0127", "REF-0128",
      ],
      independentId: "ASM-0048",
    },
    {
      path: join(repositoryRoot, "book", "volumes", "03-engineering-delivery",
        "LES-0022-reproducible-builds-dependencies", "lesson.md"),
      id: "LES-0022",
      domain: "engineering",
      route: "/book/engineering/reproducible-builds-dependencies",
      volume: "03-engineering-delivery",
      order: 7,
      prerequisiteLessonIds: ["LES-0009", "LES-0021"],
      prerequisiteCurriculumIds: ["SCM-001", "AUT-005"],
      assessmentIds: ["ASM-0049", "ASM-0050", "ASM-0051"],
      referenceIds: [
        "REF-0129", "REF-0130", "REF-0131", "REF-0132",
        "REF-0133", "REF-0134", "REF-0135", "REF-0136",
      ],
      independentId: "ASM-0051",
    },
    {
      path: join(repositoryRoot, "book", "volumes", "03-engineering-delivery",
        "LES-0023-oci-containers-docker", "lesson.md"),
      id: "LES-0023",
      domain: "engineering",
      route: "/book/engineering/oci-containers-docker",
      volume: "03-engineering-delivery",
      order: 8,
      prerequisiteLessonIds: ["LES-0011", "LES-0004", "LES-0022"],
      prerequisiteCurriculumIds: ["LNX-007", "NET-003", "BLD-001"],
      assessmentIds: ["ASM-0052", "ASM-0053", "ASM-0054"],
      referenceIds: [
        "REF-0137", "REF-0138", "REF-0139", "REF-0140",
        "REF-0141", "REF-0142", "REF-0143", "REF-0144",
      ],
      independentId: "ASM-0054",
    },
    {
      path: join(repositoryRoot, "book", "volumes", "03-engineering-delivery",
        "LES-0024-ci-cd-architecture", "lesson.md"),
      id: "LES-0024",
      domain: "engineering",
      route: "/book/engineering/ci-cd-architecture",
      volume: "03-engineering-delivery",
      order: 9,
      prerequisiteLessonIds: ["LES-0009", "LES-0021", "LES-0022", "LES-0023"],
      prerequisiteCurriculumIds: ["SCM-001", "AUT-005", "BLD-001", "CTR-001", "CTR-002"],
      assessmentIds: ["ASM-0055", "ASM-0056", "ASM-0057"],
      referenceIds: [
        "REF-0145", "REF-0146", "REF-0147", "REF-0148",
        "REF-0149", "REF-0150", "REF-0151", "REF-0152",
      ],
      independentId: "ASM-0057",
    },
    {
      path: join(repositoryRoot, "book", "volumes", "03-engineering-delivery",
        "LES-0025-ci-platform-operations", "lesson.md"),
      id: "LES-0025",
      domain: "engineering",
      route: "/book/engineering/ci-platform-operations",
      volume: "03-engineering-delivery",
      order: 10,
      prerequisiteLessonIds: ["LES-0024"],
      prerequisiteCurriculumIds: ["CI-001"],
      assessmentIds: ["ASM-0058", "ASM-0059", "ASM-0060"],
      referenceIds: [
        "REF-0153", "REF-0154", "REF-0155", "REF-0156",
        "REF-0157", "REF-0158", "REF-0159", "REF-0160",
        "REF-0161", "REF-0162", "REF-0163",
      ],
      independentId: "ASM-0060",
    },
    {
      path: join(repositoryRoot, "book", "volumes", "04-reliability-operations",
        "LES-0026-observability-foundations", "lesson.md"),
      id: "LES-0026",
      domain: "reliability",
      route: "/book/reliability/observability-foundations",
      volume: "04-reliability-operations",
      order: 1,
      prerequisiteLessonIds: ["LES-0008"],
      prerequisiteCurriculumIds: ["FND-001", "DBG-001"],
      assessmentIds: ["ASM-0061", "ASM-0062", "ASM-0063"],
      referenceIds: [
        "REF-0164", "REF-0165", "REF-0166", "REF-0167",
        "REF-0168", "REF-0169", "REF-0170", "REF-0171",
        "REF-0172",
      ],
      independentId: "ASM-0063",
    },
    {
      path: join(repositoryRoot, "book", "volumes", "04-reliability-operations",
        "LES-0027-opentelemetry-instrumentation-pipelines", "lesson.md"),
      id: "LES-0027",
      domain: "reliability",
      route: "/book/reliability/opentelemetry-instrumentation-pipelines",
      volume: "04-reliability-operations",
      order: 2,
      prerequisiteLessonIds: ["LES-0026", "LES-0018"],
      prerequisiteCurriculumIds: ["OBS-001", "AUT-002"],
      assessmentIds: ["ASM-0064", "ASM-0065", "ASM-0066"],
      referenceIds: [
        "REF-0166", "REF-0170", "REF-0173", "REF-0174",
        "REF-0175", "REF-0176", "REF-0177", "REF-0178",
        "REF-0179", "REF-0180", "REF-0181", "REF-0182",
        "REF-0183", "REF-0184",
      ],
      independentId: "ASM-0066",
    },
    {
      path: join(repositoryRoot, "book", "volumes", "04-reliability-operations", "LES-0028-prometheus-promql-grafana", "lesson.md"),
      id: "LES-0028", domain: "reliability", route: "/book/reliability/prometheus-promql-grafana", volume: "04-reliability-operations", order: 3,
      prerequisiteLessonIds: ["LES-0026", "LES-0008"], prerequisiteCurriculumIds: ["OBS-001", "DBG-001"],
      assessmentIds: ["ASM-0067", "ASM-0068", "ASM-0069"],
      referenceIds: ["REF-0167", "REF-0185", "REF-0186", "REF-0187", "REF-0188", "REF-0189", "REF-0190", "REF-0191", "REF-0192", "REF-0193", "REF-0194", "REF-0195", "REF-0196", "REF-0197", "REF-0198"],
      independentId: "ASM-0069",
    },
    {
      path: join(repositoryRoot, "book", "volumes", "04-reliability-operations", "LES-0029-structured-logging-pipelines", "lesson.md"),
      id: "LES-0029", domain: "reliability", route: "/book/reliability/structured-logging-pipelines", volume: "04-reliability-operations", order: 4,
      prerequisiteLessonIds: ["LES-0026", "LES-0008", "LES-0021"], prerequisiteCurriculumIds: ["OBS-001", "DBG-001", "AUT-005"],
      assessmentIds: ["ASM-0070", "ASM-0071", "ASM-0072"],
      referenceIds: ["REF-0199", "REF-0200", "REF-0201", "REF-0202", "REF-0203", "REF-0204", "REF-0205", "REF-0206", "REF-0207", "REF-0208", "REF-0209", "REF-0210", "REF-0211", "REF-0212", "REF-0213"],
      independentId: "ASM-0072",
    },
    {
      path: join(repositoryRoot, "book", "volumes", "04-reliability-operations", "LES-0030-alerting-dashboards-user-journeys", "lesson.md"),
      id: "LES-0030", domain: "reliability", route: "/book/reliability/alerting-dashboards-user-journeys", volume: "04-reliability-operations", order: 5,
      prerequisiteLessonIds: ["LES-0026", "LES-0008"], prerequisiteCurriculumIds: ["OBS-001", "SRE-002"],
      assessmentIds: ["ASM-0073", "ASM-0074", "ASM-0075"],
      referenceIds: ["REF-0214", "REF-0215", "REF-0216", "REF-0217", "REF-0218", "REF-0219", "REF-0220", "REF-0221", "REF-0222", "REF-0223", "REF-0224", "REF-0225", "REF-0226", "REF-0227", "REF-0228"],
      independentId: "ASM-0075",
    },
    {
      path: join(repositoryRoot, "book", "volumes", "04-reliability-operations", "LES-0031-sre-principles-risk-toil-readiness", "lesson.md"),
      id: "LES-0031", domain: "reliability", route: "/book/reliability/sre-principles-risk-toil-readiness", volume: "04-reliability-operations", order: 6,
      prerequisiteLessonIds: ["LES-0007", "LES-0008", "LES-0026"], prerequisiteCurriculumIds: ["FND-001", "DBG-001", "OBS-001"],
      assessmentIds: ["ASM-0076", "ASM-0077", "ASM-0078"],
      referenceIds: ["REF-0229", "REF-0230", "REF-0231", "REF-0232", "REF-0233", "REF-0234", "REF-0235", "REF-0236", "REF-0237", "REF-0238", "REF-0239", "REF-0240", "REF-0241", "REF-0242", "REF-0243"],
      independentId: "ASM-0078",
    },
    ...[
      ["LES-0032", "sli-slo-sla-error-budgets", 7, ["LES-0007", "LES-0008", "LES-0026"], ["FND-001", "DBG-001", "OBS-001", "SRE-001"], 79, 244],
      ["LES-0033", "incident-command-on-call-recovery", 8, ["LES-0007", "LES-0008", "LES-0026", "LES-0031", "LES-0032"], ["FND-001", "DBG-001", "OBS-001", "SRE-001", "SRE-002"], 82, 259],
      ["LES-0034", "causal-analysis-post-incident-learning", 9, ["LES-0007", "LES-0008", "LES-0026", "LES-0033"], ["FND-001", "DBG-001", "OBS-001", "SRE-003"], 85, 274],
      ["LES-0035", "capacity-performance-scaling", 10, ["LES-0003", "LES-0007", "LES-0026", "LES-0032", "LES-0033"], ["LNX-003", "FND-001", "OBS-001", "SRE-002", "SRE-003"], 88, 289],
      ["LES-0036", "resilience-patterns-failure-isolation", 11, ["LES-0013", "LES-0021", "LES-0026", "LES-0032", "LES-0035"], ["NET-003", "DST-003", "OBS-001", "SRE-002", "PERF-001"], 91, 304],
    ].map(([id, slug, order, prerequisiteLessonIds, prerequisiteCurriculumIds, assessmentStart, referenceStart]) => ({
      path: join(repositoryRoot, "book", "volumes", "04-reliability-operations", `${id}-${slug}`, "lesson.md"),
      id, domain: "reliability", route: `/book/reliability/${slug}`, volume: "04-reliability-operations", order,
      prerequisiteLessonIds, prerequisiteCurriculumIds,
      assessmentIds: Array.from({ length: 3 }, (_, index) => `ASM-${String(assessmentStart + index).padStart(4, "0")}`),
      referenceIds: Array.from({ length: 15 }, (_, index) => `REF-${String(referenceStart + index).padStart(4, "0")}`),
      independentId: `ASM-${String(assessmentStart + 2).padStart(4, "0")}`,
    })),
  ];

  for (const expected of expectations) {
    const lesson = parseJsonFrontMatter(readFileSync(expected.path, "utf8"));
    for (const field of ["id", "route", "volume", "order"]) {
      assert.equal(lesson.metadata[field], expected[field], `${expected.id} ${field}`);
    }
    assert.deepEqual(lesson.metadata.prerequisiteLessonIds, expected.prerequisiteLessonIds);
    assert.deepEqual(
      lesson.metadata.prerequisiteCurriculumIds,
      expected.prerequisiteCurriculumIds,
    );
    assert.deepEqual(lesson.metadata.assessmentIds, expected.assessmentIds);
    assert.deepEqual(lesson.metadata.referenceIds, expected.referenceIds);

    const assessments = lesson.metadata.assessmentIds.map((id) => JSON.parse(readFileSync(
      join(repositoryRoot, "book", "assessments", expected.domain, `${id}.json`), "utf8",
    )));
    assert.ok(assessments.some((assessment) => assessment.type !== "independent-transfer"));
    const independent = assessments.find((assessment) =>
      assessment.type === "independent-transfer");
    assert.equal(independent?.id, expected.independentId);
    for (const field of [
      "directAnswer", "foundation", "reasoningSteps", "seniorAnswer", "weakAnswer",
      "whyWeak", "evidence", "followUps",
    ]) assert.equal(Object.hasOwn(independent, field), false, `${independent.id} leaked ${field}`);
  }
});
