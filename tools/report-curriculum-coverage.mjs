import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const repositoryRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const matrixPath = path.join(repositoryRoot, "CONTENT_MATRIX.md");
const roleMatrixPath = path.join(repositoryRoot, "career", "target-role-matrix.md");
const volumeRoot = path.join(repositoryRoot, "book", "volumes");

function walk(root, predicate) {
  const files = [];
  for (const entry of fs.readdirSync(root, { withFileTypes: true })) {
    const absolute = path.join(root, entry.name);
    if (entry.isDirectory()) files.push(...walk(absolute, predicate));
    else if (entry.isFile() && predicate(entry.name)) files.push(absolute);
  }
  return files;
}

function parseLesson(file) {
  const source = fs.readFileSync(file, "utf8");
  const match = source.match(/^---\r?\n([\s\S]*?)\r?\n---\r?\n/);
  if (!match) throw new Error(`${path.relative(repositoryRoot, file)}: missing JSON front matter`);
  return JSON.parse(match[1]);
}

function cells(line) {
  return line.slice(1, -1).split("|").map((cell) => cell.trim());
}

const lessons = walk(volumeRoot, (name) => name === "lesson.md").map(parseLesson);
const lessonById = new Map(lessons.map((lesson) => [lesson.id, lesson]));
const owners = new Map();
for (const lesson of lessons) {
  for (const curriculumId of lesson.curriculumIds) {
    const list = owners.get(curriculumId) ?? [];
    list.push(lesson.id);
    owners.set(curriculumId, list);
  }
}

const matrixRows = fs.readFileSync(matrixPath, "utf8").split(/\r?\n/)
  .filter((line) => /^\| [A-Z][A-Z0-9]*-\d{3} \|/.test(line))
  .map((line) => {
    const row = cells(line);
    return {
      id: row[0],
      requirementCell: row[1],
      citedLessonIds: [...new Set(line.match(/LES-\d{4}/g) ?? [])],
    };
  });
const curriculumRows = matrixRows.filter((row) => !row.id.startsWith("WEB-"));
const issues = [];

for (const row of curriculumRows) {
  for (const lessonId of row.citedLessonIds) {
    if (!lessonById.has(lessonId)) issues.push(`${row.id}: cites unknown canonical lesson ${lessonId}`);
  }
  const backingLessons = new Set([...(owners.get(row.id) ?? []), ...row.citedLessonIds]);
  if (backingLessons.size === 0) {
    issues.push(`${row.id}: has neither a metadata owner nor an explicit canonical lesson citation`);
  }
}
for (const curriculumId of owners.keys()) {
  if (!curriculumRows.some((row) => row.id === curriculumId)) {
    issues.push(`${curriculumId}: lesson metadata uses an ID absent from CONTENT_MATRIX.md`);
  }
}

const requirementCoverage = new Map(Array.from({ length: 46 }, (_, index) => [index + 1, []]));
for (const row of curriculumRows) {
  for (const value of row.requirementCell.match(/\d+/g) ?? []) {
    const requirement = Number(value);
    if (requirementCoverage.has(requirement)) requirementCoverage.get(requirement).push(row.id);
  }
}
for (const [requirement, curriculumIds] of requirementCoverage) {
  if (curriculumIds.length === 0) issues.push(`requirement ${requirement}: no curriculum row`);
}

const capabilityPrefixes = new Map([
  ["Linux and systems troubleshooting", ["LNX", "DBG"]],
  ["Networking, load balancing, and transport", ["NET"]],
  ["Programming and automation", ["AUT", "SCM"]],
  ["Containers and Kubernetes", ["CTR", "K8S"]],
  ["Terraform and configuration management", ["IAC", "TFM", "CFG"]],
  ["CI/CD and zero-downtime delivery", ["CI", "GITOPS", "REL"]],
  ["Observability and SLOs", ["OBS", "SRE"]],
  ["Incidents, RCA, and prevention", ["SRE", "DBG"]],
  ["AWS and public-cloud architecture", ["AWS", "CLD", "AZR", "GCP"]],
  ["Private cloud and virtualization", ["PRV"]],
  ["Databases, queues, or data platforms", ["DST", "DMP"]],
  ["Security, governance, and cost", ["SEC", "IAM", "FIN"]],
  ["Leadership and written communication", ["ARC", "LDR", "DOC", "INT"]],
  ["AI/ML-enabled operations", ["AIO"]],
]);
const roleLines = fs.readFileSync(roleMatrixPath, "utf8").split(/\r?\n/);
const roleHeaderIndex = roleLines.findIndex((line) => line.startsWith("| Capability | Apple |"));
if (roleHeaderIndex < 0) issues.push("target-role matrix: heat-map header is missing");
const parsedRoleRows = [];
if (roleHeaderIndex >= 0) {
  for (const line of roleLines.slice(roleHeaderIndex + 2)) {
    if (!line.startsWith("|")) break;
    const row = cells(line);
    if (row.length !== 10) {
      issues.push(`target-role matrix: ${row[0] ?? "unknown row"} has ${row.length} cells; expected 10`);
      continue;
    }
    parsedRoleRows.push({ capability: row[0], signals: row.slice(1) });
  }
}
for (const row of parsedRoleRows) {
  const prefixes = capabilityPrefixes.get(row.capability);
  if (!prefixes) {
    issues.push(`${row.capability}: no curriculum capability mapping`);
    continue;
  }
  if (row.signals.some((signal) => !["Core", "Useful", "-"].includes(signal))) {
    issues.push(`${row.capability}: heat-map signals must be Core, Useful, or -`);
  }
  const mappedIds = curriculumRows.filter((entry) => prefixes.includes(entry.id.split("-")[0])).map((entry) => entry.id);
  const mappedRows = curriculumRows.filter((entry) => mappedIds.includes(entry.id));
  if (mappedRows.length === 0 || mappedRows.some((entry) => new Set([...(owners.get(entry.id) ?? []), ...entry.citedLessonIds]).size === 0)) {
    issues.push(`${row.capability}: does not resolve exclusively to backed curriculum rows`);
  }
}
for (const capability of capabilityPrefixes.keys()) {
  if (!parsedRoleRows.some((row) => row.capability === capability)) {
    issues.push(`${capability}: expected target-role capability is missing`);
  }
}

const prerequisiteOwner = new Map([...owners].map(([id, ownerIds]) => [id, ownerIds[0]]));
const edges = new Map(lessons.map((lesson) => [lesson.id, new Set()]));
for (const lesson of lessons) {
  for (const prerequisite of lesson.prerequisiteLessonIds) edges.get(lesson.id).add(prerequisite);
  for (const prerequisite of lesson.prerequisiteCurriculumIds) {
    const owner = prerequisiteOwner.get(prerequisite);
    if (owner && owner !== lesson.id) edges.get(lesson.id).add(owner);
  }
}
const visiting = new Set();
const depths = new Map();
function depth(id) {
  if (depths.has(id)) return depths.get(id);
  if (visiting.has(id)) {
    issues.push(`${id}: prerequisite cycle detected`);
    return 0;
  }
  visiting.add(id);
  const prerequisites = [...(edges.get(id) ?? [])];
  for (const prerequisite of prerequisites) {
    if (!lessonById.has(prerequisite)) issues.push(`${id}: unknown prerequisite lesson ${prerequisite}`);
  }
  const value = prerequisites.length === 0 ? 0 : 1 + Math.max(...prerequisites.filter((item) => lessonById.has(item)).map(depth), 0);
  visiting.delete(id);
  depths.set(id, value);
  return value;
}
for (const lesson of lessons) depth(lesson.id);

console.log("# Curriculum completeness coverage\n");
console.log("Static ownership and dependency audit. Passing proves traceability, not technical correctness, runtime behavior, learner transfer, or mastery.\n");
console.log("| Requirement | Curriculum rows | Canonical lessons |");
console.log("|---:|---|---|");
for (const [requirement, curriculumIds] of requirementCoverage) {
  const lessonIds = [...new Set(curriculumIds.flatMap((id) => {
    const row = curriculumRows.find((entry) => entry.id === id);
    return [...(owners.get(id) ?? []), ...(row?.citedLessonIds ?? [])];
  }))];
  console.log(`| ${requirement} | ${curriculumIds.join(", ")} | ${lessonIds.join(", ")} |`);
}

console.log("\n## Target-role capability coverage\n");
console.log("| Capability | Companies emphasizing it | Curriculum rows | Canonical lessons |");
console.log("|---|---:|---:|---:|");
for (const row of parsedRoleRows) {
  const prefixes = capabilityPrefixes.get(row.capability) ?? [];
  const mappedRows = curriculumRows.filter((entry) => prefixes.includes(entry.id.split("-")[0]));
  const curriculumIds = mappedRows.map((entry) => entry.id);
  const lessonIds = new Set(mappedRows.flatMap((entry) => [...(owners.get(entry.id) ?? []), ...entry.citedLessonIds]));
  console.log(`| ${row.capability} | ${row.signals.filter((signal) => signal !== "-").length}/9 | ${curriculumIds.length} | ${lessonIds.size} |`);
}

const roots = lessons.filter((lesson) => (edges.get(lesson.id)?.size ?? 0) === 0);
const edgeCount = [...edges.values()].reduce((total, set) => total + set.size, 0);
const maxDepth = Math.max(...depths.values());
console.log(`\nDependency graph: lessons=${lessons.length} edges=${edgeCount} roots=${roots.length} max_depth=${maxDepth}`);

if (issues.length > 0) {
  for (const issue of issues) console.error(`CURRICULUM_COVERAGE ${issue}`);
  console.error(`FAIL curriculum coverage rows=${curriculumRows.length} requirements=46 capabilities=${parsedRoleRows.length} issues=${issues.length}`);
  process.exitCode = 1;
} else {
  console.log(`PASS curriculum coverage rows=${curriculumRows.length} requirements=46 capabilities=${parsedRoleRows.length} issues=0`);
}
