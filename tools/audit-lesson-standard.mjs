import fs from "node:fs";
import path from "node:path";

const root = process.cwd();
const lessonsRoot = path.join(root, "book", "volumes");
const required = ["what you see", "terms before", "architecture map", "request or state", "failure zoom", "internals and state", "evidence table", "command decoders", "decision path", "guided ubuntu", "production transfer", "reliability, security", "traps and prevention", "memory card", "complete answers", "product-company interview", "independent transfer", "references and review"];

function walk(directory) {
  return fs.readdirSync(directory, { withFileTypes: true }).flatMap((entry) => {
    const full = path.join(directory, entry.name);
    return entry.isDirectory() ? walk(full) : entry.name === "lesson.md" ? [full] : [];
  });
}

const failures = [];
let structured = 0;
for (const file of walk(lessonsRoot)) {
  const source = fs.readFileSync(file, "utf8");
  const match = source.match(/^---\r?\n([\s\S]*?)\r?\n---\r?\n/);
  if (!match || !/"schemaVersion"\s*:\s*1/.test(match[1])) continue;
  structured += 1;
  const headings = source.slice(match[0].length)
    .replace(/^```[\s\S]*?^```\s*$/gm, "")
    .split(/\r?\n/)
    .filter((line) => /^##\s+/.test(line))
    .join(" ")
    .toLowerCase();
  const missing = required.filter((term) => !headings.includes(term));
  if (missing.length) failures.push(`${path.relative(root, file)}: missing ${missing.join(", ")}`);
}

if (failures.length) {
  console.error(`FAIL lesson-standard structured=${structured} issues=${failures.length}`);
  failures.forEach((failure) => console.error(failure));
  process.exitCode = 1;
} else console.log(`PASS lesson-standard structured=${structured} required-signals=${required.length}`);
