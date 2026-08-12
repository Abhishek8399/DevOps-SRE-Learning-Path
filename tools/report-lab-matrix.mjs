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

const rows = fs.readdirSync(labsRoot, { withFileTypes: true })
  .filter((entry) => entry.isDirectory() && /^LES-\d{4}[-]/.test(entry.name))
  .map((entry) => {
    const directory = path.join(labsRoot, entry.name);
    const present = files(directory);
    const shell = present.has("lab.sh") && present.has("verify.sh");
    const powershell = present.has("lab.ps1") && present.has("verify.ps1");
    const controller = present.has("lab_controller.py");
    const executableKind = shell ? "Bash" : powershell ? "PowerShell" : "missing";
    const strictMode = shell
      ? sourceContains(directory, "lab.sh", /set -Eeuo pipefail/) && sourceContains(directory, "lab.sh", /umask 077/)
      : powershell
        ? sourceContains(directory, "lab.ps1", /Set-StrictMode/) 
        : false;
    return Object.freeze({
      id: entry.name.match(/^LES-\d{4}/)[0],
      executableKind,
      readme: present.has("README.md"),
      verifier: shell || powershell,
      strictMode,
      controller,
    });
  })
  .sort((a, b) => a.id.localeCompare(b.id));

const missing = rows.filter((row) => !row.readme || !row.verifier || !row.strictMode);
console.log("# Canonical local lab matrix");
console.log("");
console.log("Static inventory only. `present` means a checked-in contract exists; it does not mean the lab ran, cleaned up, or proves learner capability.");
console.log("");
console.log("| Lesson | Runner | README | Verifier | Safety preamble | Controller | Runtime evidence |");
console.log("|---|---|---|---|---|---|---|");
for (const row of rows) {
  console.log(`| ${row.id} | ${row.executableKind} | ${row.readme ? "present" : "missing"} | ${row.verifier ? "present" : "missing"} | ${row.strictMode ? "present" : "missing"} | ${row.controller ? "present" : "none"} | not assessed |`);
}
console.log("");
console.log(`SUMMARY canonical_labs=${rows.length} incomplete_static_contracts=${missing.length}`);
if (missing.length) {
  console.error(`FAIL lab matrix: incomplete static contracts: ${missing.map((row) => row.id).join(", ")}`);
  process.exitCode = 1;
} else {
  console.log("PASS lab matrix: every canonical lab has a README, paired verifier, and runner safety preamble");
}
