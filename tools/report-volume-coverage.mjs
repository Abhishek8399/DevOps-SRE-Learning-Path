import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const repositoryRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const volumeRoot = path.join(repositoryRoot, "book", "volumes");
const assessmentRoot = path.join(repositoryRoot, "book", "assessments");

function walk(root, predicate) {
  const result = [];
  for (const entry of fs.readdirSync(root, { withFileTypes: true })) {
    const absolute = path.join(root, entry.name);
    if (entry.isDirectory()) result.push(...walk(absolute, predicate));
    else if (entry.isFile() && predicate(entry.name)) result.push(absolute);
  }
  return result;
}

function parseLesson(file) {
  const source = fs.readFileSync(file, "utf8");
  const match = source.match(/^---\r?\n([\s\S]*?)\r?\n---\r?\n/);
  if (!match) throw new Error(`${path.relative(repositoryRoot, file)}: missing JSON front matter`);
  return { metadata: JSON.parse(match[1]), body: source.slice(match[0].length) };
}

const assessmentsByLesson = new Map();
for (const file of walk(assessmentRoot, (name) => /^ASM-\d{4}\.json$/.test(name))) {
  const record = JSON.parse(fs.readFileSync(file, "utf8"));
  const records = assessmentsByLesson.get(record.lessonId) ?? [];
  records.push(record);
  assessmentsByLesson.set(record.lessonId, records);
}

const volumes = new Map();
const issues = [];
for (const file of walk(volumeRoot, (name) => name === "lesson.md")) {
  const { metadata, body } = parseLesson(file);
  const assessments = assessmentsByLesson.get(metadata.id) ?? [];
  const independent = assessments.filter((record) => record.type === "independent-transfer");
  const sectionCount = body.split(/\r?\n/).filter((line) => /^##\s+\S/.test(line)).length;
  const labPaths = (metadata.labs ?? [])
    .filter((lab) => typeof lab.path === "string")
    .map((lab) => path.join(repositoryRoot, lab.path));
  const facts = {
    id: metadata.id,
    sections: sectionCount,
    diagrams: metadata.diagrams?.length ?? 0,
    commands: metadata.commands?.length ?? 0,
    incidents: metadata.incidents?.length ?? 0,
    labs: metadata.labs?.length ?? 0,
    assessments: assessments.length,
    independent: independent.length,
    references: metadata.referenceIds?.length ?? 0,
    words: body.trim().split(/\s+/u).filter(Boolean).length,
  };

  const required = [
    [facts.sections === 18, `expected 18 H2 sections, found ${facts.sections}`],
    [facts.diagrams > 0, "has no structured diagram"],
    [facts.commands > 0, "has no command decision contract"],
    [facts.incidents > 0, "has no incident scenario"],
    [facts.labs > 0, "has no lab contract"],
    [facts.assessments === 3, `expected 3 assessments, found ${facts.assessments}`],
    [facts.independent === 1, `expected 1 answer-isolated transfer, found ${facts.independent}`],
    [facts.references > 0, "has no reference relationship"],
    [labPaths.length > 0, "has no checked-in lab path"],
    [labPaths.every((labPath) => fs.existsSync(labPath)), "declares a missing lab path"],
  ];
  for (const [passes, message] of required) {
    if (!passes) issues.push(`${metadata.id}: ${message}`);
  }

  const volume = volumes.get(metadata.volume) ?? [];
  volume.push(facts);
  volumes.set(metadata.volume, volume);
}

console.log("# Canonical volume coverage\n");
console.log("Static authored-structure audit. Passing confirms declared teaching components and relationships, not technical review, runtime execution, learner transfer, or mastery.\n");
console.log("| Volume | Lessons | Words | Diagrams | Commands | Incidents | Labs | Assessments | Independent transfers | References |");
console.log("|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|");
let totals = { lessons: 0, words: 0, diagrams: 0, commands: 0, incidents: 0, labs: 0, assessments: 0, independent: 0, references: 0 };
for (const [volume, lessons] of [...volumes].sort(([left], [right]) => left.localeCompare(right))) {
  const sum = (field) => lessons.reduce((total, lesson) => total + lesson[field], 0);
  const row = {
    lessons: lessons.length,
    words: sum("words"),
    diagrams: sum("diagrams"),
    commands: sum("commands"),
    incidents: sum("incidents"),
    labs: sum("labs"),
    assessments: sum("assessments"),
    independent: sum("independent"),
    references: sum("references"),
  };
  for (const key of Object.keys(totals)) totals[key] += row[key];
  console.log(`| ${volume} | ${row.lessons} | ${row.words} | ${row.diagrams} | ${row.commands} | ${row.incidents} | ${row.labs} | ${row.assessments} | ${row.independent} | ${row.references} |`);
}
console.log(`| **Total** | **${totals.lessons}** | **${totals.words}** | **${totals.diagrams}** | **${totals.commands}** | **${totals.incidents}** | **${totals.labs}** | **${totals.assessments}** | **${totals.independent}** | **${totals.references}** |`);

if (issues.length > 0) {
  for (const issue of issues) console.error(`VOLUME_COVERAGE ${issue}`);
  console.error(`FAIL volume coverage lessons=${totals.lessons} volumes=${volumes.size} issues=${issues.length}`);
  process.exitCode = 1;
} else {
  console.log(`\nPASS volume coverage lessons=${totals.lessons} volumes=${volumes.size} issues=0`);
}
