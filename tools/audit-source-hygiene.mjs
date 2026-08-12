import { execFileSync } from "node:child_process";
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const textExtensions = new Set([
  ".css", ".cmd", ".html", ".js", ".json", ".md", ".mjs", ".ps1", ".sh", ".ts", ".tsx", ".txt", ".yaml", ".yml",
]);
const removedPersonalName = ["Abhi", "shek"].join("");

const rules = Object.freeze([
  { id: "merge-conflict", expression: /^(?:<<<<<<<|=======|>>>>>>>)/mu },
  { id: "private-key", expression: /-----BEGIN (?:RSA |EC |OPENSSH )?PRIVATE KEY-----/u },
  { id: "github-token", expression: /\bgh[pousr]_[A-Za-z0-9_]{36,255}\b/u },
  { id: "aws-access-key", expression: /\b(?:AKIA|ASIA)[0-9A-Z]{16}\b/u },
  { id: "slack-token", expression: /\bxox(?:b|p|a|r)-[A-Za-z0-9-]{20,}\b/u },
  { id: "removed-personal-name", expression: new RegExp(`\\b${removedPersonalName}\\b`, "iu") },
]);

function trackedFiles() {
  return execFileSync("git", ["-C", root, "ls-files", "-z"], { encoding: "utf8" })
    .split("\0")
    .filter(Boolean)
    .map((value) => value.split(path.sep).join("/"));
}

function isTextCandidate(file) {
  return textExtensions.has(path.extname(file).toLowerCase());
}

function lineForMatch(source, index) {
  return source.slice(0, index).split("\n").length;
}

const findings = [];
let scanned = 0;
for (const file of trackedFiles().filter(isTextCandidate)) {
  const absolute = path.join(root, file);
  const source = fs.readFileSync(absolute, "utf8");
  scanned += 1;
  for (const rule of rules) {
    const match = source.match(rule.expression);
    if (match?.index !== undefined) {
      findings.push({ file, line: lineForMatch(source, match.index), rule: rule.id });
    }
  }
}

console.log(`SOURCE_HYGIENE scanned_text_files=${scanned} findings=${findings.length}`);
for (const finding of findings) {
  console.error(`SOURCE_HYGIENE rule=${finding.rule} file=${finding.file}:${finding.line}`);
}

if (findings.length > 0) {
  console.error("FAIL source hygiene: remove or rotate sensitive material and resolve conflict markers before committing");
  process.exitCode = 1;
} else {
  console.log("PASS source hygiene: tracked text has no configured secret, conflict, or removed-name marker");
}
