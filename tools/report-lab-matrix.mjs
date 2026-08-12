import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const labsRoot = path.join(root, "book", "labs");

function files(directory) {
  return new Set(fs.readdirSync(directory, { withFileTypes: true })
    .filter((entry) => entry.isFile())
    .map((entry) => entry.name));
}

function sourceContains(directory, file, expression) {
  return fs.existsSync(path.join(directory, file))
    && expression.test(fs.readFileSync(path.join(directory, file), "utf8"));
}

function everySourceContains(directory, filesToCheck, expression) {
  return filesToCheck.every((file) => sourceContains(directory, file, expression));
}

function noSourceMatches(directory, filesToCheck, expression) {
  return filesToCheck.every((file) => !sourceContains(directory, file, expression));
}

const rows = fs.readdirSync(labsRoot, { withFileTypes: true })
  .filter((entry) => entry.isDirectory() && /^LES-\d{4}[-]/.test(entry.name))
  .map((entry) => {
    const directory = path.join(labsRoot, entry.name);
    const present = files(directory);
    const shellFiles = ["lab.sh", "verify.sh"];
    const powershellFiles = ["lab.ps1", "verify.ps1"];
    const shell = shellFiles.every((file) => present.has(file));
    const powershell = powershellFiles.every((file) => present.has(file));
    const controller = present.has("lab_controller.py");
    const executableKind = shell ? "Bash" : powershell ? "PowerShell" : "missing";
    const strictMode = shell
      ? everySourceContains(directory, shellFiles, /set -Eeuo pipefail/) && everySourceContains(directory, shellFiles, /umask 077/)
      : powershell
        ? everySourceContains(directory, powershellFiles, /Set-StrictMode/) && everySourceContains(directory, powershellFiles, /\$ErrorActionPreference\s*=\s*["']Stop["']/)
        : false;
    const prohibitedPatterns = shell
      ? noSourceMatches(directory, shellFiles, /(^|[^[:alnum:]_])eval([[:space:]]|$)/m)
      : powershell
        ? noSourceMatches(directory, powershellFiles, /Invoke-Expression\b/i)
        : false;
    return Object.freeze({
      id: entry.name.match(/^LES-\d{4}/)[0],
      executableKind,
      readme: present.has("README.md"),
      verifier: shell || powershell,
      strictMode,
      prohibitedPatterns,
      controller,
    });
  })
  .sort((a, b) => a.id.localeCompare(b.id));

const missing = rows.filter((row) => !row.readme || !row.verifier || !row.strictMode || !row.prohibitedPatterns);
console.log("# Canonical local lab matrix");
console.log("");
console.log("Static inventory only. `present` means a checked-in contract exists; it does not mean the lab ran, cleaned up, or proves learner capability.");
console.log("");
console.log("| Lesson | Runner | README | Verifier | Safety preamble | No dynamic eval | Controller | Runtime evidence |");
console.log("|---|---|---|---|---|---|---|---|");
for (const row of rows) {
  console.log(`| ${row.id} | ${row.executableKind} | ${row.readme ? "present" : "missing"} | ${row.verifier ? "present" : "missing"} | ${row.strictMode ? "present" : "missing"} | ${row.prohibitedPatterns ? "present" : "missing"} | ${row.controller ? "present" : "none"} | not assessed |`);
}
console.log("");
console.log(`SUMMARY canonical_labs=${rows.length} incomplete_static_contracts=${missing.length}`);
if (missing.length) {
  console.error(`FAIL lab matrix: incomplete static contracts: ${missing.map((row) => row.id).join(", ")}`);
  process.exitCode = 1;
} else {
  console.log("PASS lab matrix: every canonical lab has a README, paired runner/verifier safety preambles, and no dynamic-evaluation primitive");
}
