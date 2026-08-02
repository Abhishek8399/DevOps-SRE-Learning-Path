export const REQUIRED_STRUCTURED_SECTIONS = [
  "What you see and first thought",
  "Terms before commands",
  "Architecture map",
  "Request or state path",
  "Failure zoom",
  "Internals and state ownership",
  "Evidence table",
  "Command decoders",
  "Decision path",
  "Guided Ubuntu lab",
  "Production transfer",
  "Reliability, security, observability, capacity, and cost",
  "Traps and prevention",
  "Memory card and retrieval",
  "Complete answers",
  "Product-company interview",
  "Independent transfer and rubric",
  "References and review",
] as const;

type ExpectedBranch = Readonly<{
  when: string;
  meaning: string;
  nextEvidence: string;
}>;

export type StructuredCommand = Readonly<{
  id: string;
  question: string;
  risk: string;
  command: string;
  runFrom: string;
  expectedBranches: readonly ExpectedBranch[];
  proves: string;
  doesNotProve: string;
  cleanup?: string;
}>;

export type StructuredLab = Readonly<{
  id: string;
  title: string;
  mode: "guided" | "independent";
  environment: string;
  timeMinutes: number;
  privilege: string;
  network: string;
  changes: readonly string[];
  abortConditions: readonly string[];
  recovery: string;
  cleanupProof: string;
  path?: string;
}>;

export type StructuredLessonMetadata = Readonly<{
  schemaVersion: 1;
  kind: "lesson";
  id: string;
  aliases: readonly string[];
  curriculumIds: readonly string[];
  slug: string;
  route: string;
  order: number;
  volume: string;
  title: string;
  summary: string;
  domain: string;
  level: Readonly<{ from: string; to: string }>;
  estimatedMinutes: number;
  prerequisiteLessonIds: readonly string[];
  prerequisiteCurriculumIds: readonly string[];
  testedEnvironments: readonly Readonly<{
    platform: string;
    version: string;
    support: string;
    notes?: string;
  }>[];
  targetRoles: readonly string[];
  learningObjectives: readonly string[];
  productionSignals: readonly string[];
  diagrams: readonly Readonly<{
    id: string;
    title: string;
    direction: string;
    boundaries: readonly string[];
    evidencePoints: readonly string[];
    textAlternative: string;
  }>[];
  commands: readonly StructuredCommand[];
  labs: readonly StructuredLab[];
  incidents: readonly Readonly<{
    id: string;
    signal: string;
    firstThought: string;
    safePath: string;
    trap: string;
  }>[];
  assessmentIds: readonly string[];
  referenceIds: readonly string[];
  contentStatus: string;
  masteryBoundary: string;
  lastReviewed: string;
  reviewAfter: string;
  limitations: readonly string[];
}>;

type AssessmentRubricRow = Readonly<{
  criterion: string;
  points: number;
  observableEvidence: string;
}>;

type AssessmentBase = Readonly<{
  schemaVersion: 1;
  kind: "assessment";
  id: string;
  lessonId: string;
  type: string;
  difficulty: string;
  prompt: string;
  rubric: readonly AssessmentRubricRow[];
  maximumScore: number;
  masteryBoundary: string;
  lastReviewed: string;
  reviewAfter: string;
}>;

export type AnsweredAssessment = AssessmentBase & Readonly<{
  type: "recall" | "diagnostic" | "production" | "guided-transfer" | "interview";
  directAnswer: string;
  foundation: string;
  reasoningSteps: readonly string[];
  seniorAnswer: string;
  weakAnswer: string;
  whyWeak: string;
  evidence: readonly Readonly<{
    signal: string;
    proves: string;
    doesNotProve: string;
  }>[];
  followUps: readonly Readonly<{ prompt: string; answer: string }>[];
}>;

export type IndependentAssessment = AssessmentBase & Readonly<{
  type: "independent-transfer";
  deliverables: readonly string[];
  evidenceRequirements: readonly string[];
  reviewPolicy: "reviewer-only-no-model-answer";
}>;

export type StructuredAssessment = AnsweredAssessment | IndependentAssessment;

export type StructuredReference = Readonly<{
  schemaVersion: 1;
  kind: "reference";
  id: string;
  title: string;
  organization: string;
  url: string;
  sourceType: string;
  versionOrDate: string;
  lessonIds: readonly string[];
  topics: readonly string[];
  relevance: string;
  usagePolicy: string;
  lastReviewed: string;
  reviewAfter: string;
}>;

export type MarkdownInline = Readonly<{
  kind: "text" | "strong" | "code" | "link";
  text: string;
  href?: string;
}>;

export type MarkdownBlock =
  | Readonly<{ kind: "heading"; level: 3 | 4; content: readonly MarkdownInline[] }>
  | Readonly<{ kind: "paragraph"; content: readonly MarkdownInline[] }>
  | Readonly<{ kind: "quote"; content: readonly MarkdownInline[] }>
  | Readonly<{ kind: "unordered-list"; items: readonly (readonly MarkdownInline[])[] }>
  | Readonly<{ kind: "ordered-list"; items: readonly (readonly MarkdownInline[])[] }>
  | Readonly<{ kind: "code"; language: string; value: string }>
  | Readonly<{
      kind: "table";
      headers: readonly (readonly MarkdownInline[])[];
      rows: readonly (readonly (readonly MarkdownInline[])[])[];
    }>;

export type StructuredSection = Readonly<{
  title: (typeof REQUIRED_STRUCTURED_SECTIONS)[number];
  anchor: string;
  blocks: readonly MarkdownBlock[];
}>;

export type ParsedStructuredLesson = Readonly<{
  metadata: StructuredLessonMetadata;
  title: string;
  sections: readonly StructuredSection[];
}>;

export type StructuredLessonBundle = Readonly<{
  lesson: ParsedStructuredLesson;
  assessments: readonly StructuredAssessment[];
  references: readonly StructuredReference[];
}>;

const answerFields = [
  "directAnswer", "foundation", "reasoningSteps", "seniorAnswer", "weakAnswer",
  "whyWeak", "evidence", "followUps",
] as const;

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

function requireRecord(value: unknown, label: string): Record<string, unknown> {
  if (!isRecord(value)) throw new Error(`${label} must be an object`);
  return value;
}

function requireString(record: Record<string, unknown>, field: string, label: string): string {
  const value = record[field];
  if (typeof value !== "string" || value.trim() === "") {
    throw new Error(`${label}.${field} must be a non-empty string`);
  }
  return value;
}

function requireStringArray(
  record: Record<string, unknown>,
  field: string,
  label: string,
): readonly string[] {
  const value = record[field];
  if (!Array.isArray(value) || value.some((item) => typeof item !== "string")) {
    throw new Error(`${label}.${field} must be an array of strings`);
  }
  return value;
}

export function headingAnchor(value: string): string {
  const anchor = value.toLocaleLowerCase("en-US")
    .replace(/[`*_~]/g, "")
    .replace(/[^a-z0-9\s-]/g, "")
    .trim()
    .replace(/\s+/g, "-")
    .replace(/-+/g, "-");
  if (!anchor) throw new Error(`heading does not produce a safe anchor: ${value}`);
  return anchor;
}

export function isSafeStructuredHref(value: string): boolean {
  if (/^#[a-z0-9]+(?:-[a-z0-9]+)*$/.test(value)) return true;
  if (/^\/book\/[a-z0-9]+(?:\/[a-z0-9-]+)+(?:#[a-z0-9]+(?:-[a-z0-9]+)*)?$/.test(value)) {
    return true;
  }
  if (!value.startsWith("https://")) return false;
  try {
    const parsed = new URL(value);
    return parsed.href === value && parsed.username === "" && parsed.password === "";
  } catch {
    return false;
  }
}

export function parseMarkdownInline(value: string): readonly MarkdownInline[] {
  const result: MarkdownInline[] = [];
  const token = /(`[^`\n]+`|\*\*[^*\n]+\*\*|\[[^\]\n]+\]\([^\s)]+\))/g;
  let cursor = 0;
  for (const match of value.matchAll(token)) {
    const index = match.index ?? 0;
    if (index > cursor) result.push({ kind: "text", text: value.slice(cursor, index) });
    const raw = match[0];
    if (raw.startsWith("`")) {
      result.push({ kind: "code", text: raw.slice(1, -1) });
    } else if (raw.startsWith("**")) {
      result.push({ kind: "strong", text: raw.slice(2, -2) });
    } else {
      const link = raw.match(/^\[([^\]]+)\]\(([^)]+)\)$/);
      if (!link || !isSafeStructuredHref(link[2])) {
        throw new Error(`unsafe or malformed structured lesson link: ${raw}`);
      }
      result.push({ kind: "link", text: link[1], href: link[2] });
    }
    cursor = index + raw.length;
  }
  if (cursor < value.length) result.push({ kind: "text", text: value.slice(cursor) });
  return result.length > 0 ? result : [{ kind: "text", text: value }];
}

function splitTableRow(value: string): string[] {
  const trimmed = value.trim();
  return trimmed.replace(/^\|/, "").replace(/\|$/, "")
    .split(/(?<!\\)\|/).map((cell) => cell.trim().replace(/\\\|/g, "|"));
}

function isTableDivider(value: string): boolean {
  const cells = splitTableRow(value);
  return cells.length > 0 && cells.every((cell) => /^:?-{3,}:?$/.test(cell));
}

type MarkdownFence = Readonly<{
  character: "`" | "~";
  length: number;
  language: string;
}>;

function parseFenceOpening(value: string): MarkdownFence | null {
  const marker = value.match(/^\s{0,3}(`{3,}|~{3,})(.*)$/);
  if (!marker || (marker[1][0] === "`" && marker[2].includes("`"))) return null;
  const firstInfoToken = marker[2].trim().split(/\s+/, 1)[0] ?? "";
  const language = /^[a-z0-9_-]+$/i.test(firstInfoToken)
    ? firstInfoToken.toLowerCase()
    : "";
  return {
    character: marker[1][0] as "`" | "~",
    length: marker[1].length,
    language,
  };
}

function closesFence(value: string, fence: MarkdownFence): boolean {
  const marker = value.match(/^\s{0,3}(`{3,}|~{3,})\s*$/);
  return Boolean(marker
    && marker[1][0] === fence.character
    && marker[1].length >= fence.length);
}

function startsBlock(lines: readonly string[], index: number): boolean {
  const value = lines[index] ?? "";
  if (value.trim() === "") return true;
  if (/^#{3,4}\s+/.test(value) || parseFenceOpening(value) || /^>\s?/.test(value)) return true;
  if (/^[-*]\s+/.test(value) || /^\d+\.\s+/.test(value)) return true;
  return value.includes("|") && isTableDivider(lines[index + 1] ?? "");
}

export function parseMarkdownBlocks(source: string): readonly MarkdownBlock[] {
  const lines = source.split(/\r?\n/);
  const blocks: MarkdownBlock[] = [];
  let index = 0;

  while (index < lines.length) {
    const line = lines[index];
    if (line.trim() === "") {
      index += 1;
      continue;
    }
    const heading = line.match(/^(#{3,4})\s+(.+)$/);
    if (heading) {
      blocks.push({
        kind: "heading",
        level: heading[1].length as 3 | 4,
        content: parseMarkdownInline(heading[2]),
      });
      index += 1;
      continue;
    }
    const fence = parseFenceOpening(line);
    if (fence) {
      const content: string[] = [];
      index += 1;
      while (index < lines.length && !closesFence(lines[index], fence)) {
        content.push(lines[index]);
        index += 1;
      }
      if (index >= lines.length) throw new Error("structured lesson has an unclosed code fence");
      blocks.push({ kind: "code", language: fence.language, value: content.join("\n") });
      index += 1;
      continue;
    }
    if (line.includes("|") && isTableDivider(lines[index + 1] ?? "")) {
      const headers = splitTableRow(line).map(parseMarkdownInline);
      const rows: (readonly MarkdownInline[])[][] = [];
      index += 2;
      while (index < lines.length && lines[index].includes("|") && lines[index].trim() !== "") {
        const cells = splitTableRow(lines[index]);
        if (cells.length !== headers.length) {
          throw new Error(`structured lesson table row has ${cells.length} cells; expected ${headers.length}`);
        }
        rows.push(cells.map(parseMarkdownInline));
        index += 1;
      }
      blocks.push({ kind: "table", headers, rows });
      continue;
    }
    const unordered = /^[-*]\s+/.test(line);
    const ordered = /^\d+\.\s+/.test(line);
    if (unordered || ordered) {
      const items: (readonly MarkdownInline[])[] = [];
      const pattern = unordered ? /^[-*]\s+(.+)$/ : /^\d+\.\s+(.+)$/;
      while (index < lines.length) {
        const item = lines[index].match(pattern);
        if (!item) break;
        items.push(parseMarkdownInline(item[1]));
        index += 1;
      }
      blocks.push({ kind: unordered ? "unordered-list" : "ordered-list", items });
      continue;
    }
    if (/^>\s?/.test(line)) {
      const quote: string[] = [];
      while (index < lines.length && /^>\s?/.test(lines[index])) {
        quote.push(lines[index].replace(/^>\s?/, ""));
        index += 1;
      }
      blocks.push({ kind: "quote", content: parseMarkdownInline(quote.join(" ")) });
      continue;
    }
    const paragraph: string[] = [line.trim()];
    index += 1;
    while (index < lines.length && !startsBlock(lines, index)) {
      paragraph.push(lines[index].trim());
      index += 1;
    }
    blocks.push({ kind: "paragraph", content: parseMarkdownInline(paragraph.join(" ")) });
  }
  return blocks;
}

export function parseStructuredLesson(raw: string): ParsedStructuredLesson {
  const lines = raw.replace(/^\uFEFF/, "").split(/\r?\n/);
  if (lines[0]?.trim() !== "---") throw new Error("structured lesson front matter is missing");
  const closing = lines.findIndex((line, index) => index > 0 && line.trim() === "---");
  if (closing < 2) throw new Error("structured lesson front matter is unclosed or empty");

  let metadataValue: unknown;
  try {
    metadataValue = JSON.parse(lines.slice(1, closing).join("\n"));
  } catch (error) {
    throw new Error("structured lesson front matter is not strict JSON", { cause: error });
  }
  const metadataRecord = requireRecord(metadataValue, "lesson");
  for (const field of ["id", "slug", "route", "title", "summary", "domain", "volume"] as const) {
    requireString(metadataRecord, field, "lesson");
  }
  for (const field of ["aliases", "curriculumIds", "assessmentIds", "referenceIds"] as const) {
    requireStringArray(metadataRecord, field, "lesson");
  }
  if (metadataRecord.schemaVersion !== 1 || metadataRecord.kind !== "lesson") {
    throw new Error("structured lesson requires schemaVersion 1 and kind lesson");
  }
  if (!Number.isInteger(metadataRecord.order)) throw new Error("lesson.order must be an integer");

  const bodyLines = lines.slice(closing + 1);
  const titleLine = bodyLines.find((line) => /^#\s+/.test(line));
  if (!titleLine) throw new Error("structured lesson body requires one level-one title");
  const title = titleLine.replace(/^#\s+/, "").trim();
  const sectionSources: { title: string; lines: string[] }[] = [];
  let active: { title: string; lines: string[] } | null = null;
  let fence: MarkdownFence | null = null;
  for (const line of bodyLines) {
    if (fence) {
      if (active) active.lines.push(line);
      if (closesFence(line, fence)) fence = null;
      continue;
    }
    const openingFence = parseFenceOpening(line);
    if (openingFence) {
      fence = openingFence;
      if (active) active.lines.push(line);
      continue;
    }
    const heading = line.match(/^##\s+(.+)$/);
    if (heading) {
      active = { title: heading[1].trim(), lines: [] };
      sectionSources.push(active);
    } else if (active) {
      active.lines.push(line);
    }
  }
  if (fence) throw new Error("structured lesson body has an unclosed code fence");
  const actualTitles = sectionSources.map((section) => section.title);
  if (JSON.stringify(actualTitles) !== JSON.stringify(REQUIRED_STRUCTURED_SECTIONS)) {
    throw new Error("structured lesson sections do not match the canonical ordered set");
  }

  return {
    metadata: metadataRecord as StructuredLessonMetadata,
    title,
    sections: sectionSources.map((section) => ({
      title: section.title as StructuredSection["title"],
      anchor: headingAnchor(section.title),
      blocks: parseMarkdownBlocks(section.lines.join("\n")),
    })),
  };
}

export function parseStructuredAssessment(value: unknown): StructuredAssessment {
  const record = requireRecord(value, "assessment");
  for (const field of ["id", "lessonId", "type", "difficulty", "prompt"] as const) {
    requireString(record, field, "assessment");
  }
  if (record.schemaVersion !== 1 || record.kind !== "assessment") {
    throw new Error("structured assessment requires schemaVersion 1 and kind assessment");
  }
  if (!Array.isArray(record.rubric) || !Number.isInteger(record.maximumScore)) {
    throw new Error("structured assessment requires a rubric and integer maximumScore");
  }
  if (record.type === "independent-transfer") {
    for (const field of answerFields) {
      if (Object.hasOwn(record, field)) throw new Error(`independent assessment leaks ${field}`);
    }
    requireStringArray(record, "deliverables", "assessment");
    requireStringArray(record, "evidenceRequirements", "assessment");
    if (record.reviewPolicy !== "reviewer-only-no-model-answer") {
      throw new Error("independent assessment requires reviewer-only answer isolation");
    }
    return record as IndependentAssessment;
  }
  for (const field of [
    "directAnswer", "foundation", "seniorAnswer", "weakAnswer", "whyWeak",
  ] as const) requireString(record, field, "assessment");
  requireStringArray(record, "reasoningSteps", "assessment");
  if (!Array.isArray(record.evidence) || !Array.isArray(record.followUps)) {
    throw new Error("answered assessment requires evidence and followUps arrays");
  }
  return record as AnsweredAssessment;
}

export function parseStructuredReference(value: unknown): StructuredReference {
  const record = requireRecord(value, "reference");
  for (const field of [
    "id", "title", "organization", "url", "sourceType", "versionOrDate", "relevance",
    "usagePolicy", "lastReviewed", "reviewAfter",
  ] as const) requireString(record, field, "reference");
  requireStringArray(record, "lessonIds", "reference");
  requireStringArray(record, "topics", "reference");
  if (record.schemaVersion !== 1 || record.kind !== "reference"
    || !isSafeStructuredHref(record.url as string)) {
    throw new Error("structured reference has invalid identity or URL");
  }
  return record as StructuredReference;
}
