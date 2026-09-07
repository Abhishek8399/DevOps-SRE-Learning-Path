import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const repositoryRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");

function filesUnder(relativeRoot, predicate) {
  const root = path.join(repositoryRoot, relativeRoot);
  const found = [];
  const visit = (directory) => {
    for (const entry of fs.readdirSync(directory, { withFileTypes: true })) {
      const absolute = path.join(directory, entry.name);
      if (entry.isDirectory()) visit(absolute);
      else if (entry.isFile() && predicate(entry.name, absolute)) found.push(absolute);
    }
  };
  visit(root);
  return found;
}

function read(relativePath) {
  return fs.readFileSync(path.join(repositoryRoot, relativePath), "utf8");
}

const lessons = filesUnder("book/volumes", (name) => name === "lesson.md");
const assessments = filesUnder("book/assessments", (name) => /^ASM-\d{4}\.json$/.test(name));
const references = filesUnder("book/references", (name) => /^REF-\d{4}\.json$/.test(name));
const stagedLessons = filesUnder("drafts", (name) => name === "lesson.md");
const volumes = new Set(lessons.map((file) => path.relative(
  path.join(repositoryRoot, "book", "volumes"), file,
).split(path.sep)[0]));
const labRoot = path.join(repositoryRoot, "book", "labs");
const labs = fs.readdirSync(labRoot, { withFileTypes: true }).filter((entry) => (
  entry.isDirectory()
  && /^LES-\d{4}-/.test(entry.name)
  && ["lab.sh", "lab.ps1"].some((name) => fs.existsSync(path.join(labRoot, entry.name, name)))
));

const state = {
  lessons: lessons.length,
  assessments: assessments.length,
  references: references.length,
  volumes: volumes.size,
  labs: labs.length,
  stagedLessons: stagedLessons.length,
};

const requiredFragments = new Map([
  ["BOOK_SPEC.md", [
    `${state.lessons} schema-backed lessons`,
    `${state.assessments} assessments`,
    `${state.references.toLocaleString("en-US")} references`,
    `${state.labs} checked-in local lab contracts`,
  ]],
  ["CONTENT_MATRIX.md", [
    `${state.lessons} structured lessons`,
    `${state.assessments} assessments`,
    `${state.references.toLocaleString("en-US")} references`,
    `${state.labs} local lab contracts`,
  ]],
  ["MASTER_PLAN.md", [
    `${state.lessons} lessons`,
    `${state.assessments} assessments`,
    `${state.references.toLocaleString("en-US")} references`,
    `all ${state.labs} canonical local lab contracts`,
  ]],
  ["PROGRESS.md", [
    `${state.lessons} structured lessons`,
    `${state.assessments} assessments`,
    `${state.references.toLocaleString("en-US")} references`,
    `${state.labs} local lab contracts`,
  ]],
  ["UI_AUDIT.md", [
    `all ${state.lessons} canonical lessons`,
    `${state.lessons}-chapter/${state.volumes}-volume relationship`,
  ]],
]);

const issues = [];
for (const [file, fragments] of requiredFragments) {
  const text = read(file);
  for (const fragment of fragments) {
    if (!text.includes(fragment)) issues.push(`${file}: missing current-state fragment ${JSON.stringify(fragment)}`);
  }
}

if (state.stagedLessons !== 0) {
  issues.push(`drafts: expected zero staged lesson bodies, found ${state.stagedLessons}`);
}

const activeMemory = ["BOOK_SPEC.md", "MASTER_PLAN.md", "UI_AUDIT.md"];
const obsoleteClaims = [
  /twenty-six routed/i,
  /twenty-one structured/i,
  /twenty-two structured/i,
  /26 canonical lessons plus 66/i,
  /remaining authored lesson packages/i,
  /quarantined `LES-/i,
  /Thirty-six routes/i,
  /all 26 lesson routes/i,
  /2,268 tracked text files/i,
  /full-tree `npm ci` reported 15 findings/i,
  /temporary no-local clone at `eee5ab4`/i,
  /Current-revision clone quality gates/i,
];
for (const file of activeMemory) {
  const lines = read(file).split(/\r?\n/);
  lines.forEach((line, index) => {
    for (const pattern of obsoleteClaims) {
      if (pattern.test(line)) issues.push(`${file}:${index + 1}: obsolete current-state claim matches ${pattern}`);
    }
  });
}

if (issues.length > 0) {
  for (const issue of issues) console.error(`PROJECT_MEMORY ${issue}`);
  console.error(`FAIL project memory issues=${issues.length} state=${JSON.stringify(state)}`);
  process.exitCode = 1;
} else {
  console.log(`PASS project memory lessons=${state.lessons} volumes=${state.volumes} assessments=${state.assessments} references=${state.references} labs=${state.labs} staged_lessons=${state.stagedLessons}`);
}
