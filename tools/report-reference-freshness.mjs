import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { evaluateReferenceFreshness, parseIsoDate } from "./lib/reference-freshness.mjs";

const repositoryRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");

function usage(message) {
  if (message) console.error(`ERROR ${message}`);
  console.error("Usage: node tools/report-reference-freshness.mjs [--as-of YYYY-MM-DD] [--warn-days N] [--fail-overdue] [--json]");
  process.exit(2);
}

function parseArguments(args) {
  const options = { asOf: new Date().toISOString().slice(0, 10), warnDays: 90, failOverdue: false, json: false };
  for (let index = 0; index < args.length; index += 1) {
    const argument = args[index];
    if (argument === "--as-of") options.asOf = args[++index];
    else if (argument === "--warn-days") options.warnDays = Number(args[++index]);
    else if (argument === "--fail-overdue") options.failOverdue = true;
    else if (argument === "--json") options.json = true;
    else usage(`unknown argument: ${argument}`);
  }
  try {
    parseIsoDate(options.asOf, "--as-of");
  } catch (error) {
    usage(error.message);
  }
  if (!Number.isInteger(options.warnDays) || options.warnDays < 0 || options.warnDays > 3650) {
    usage("--warn-days must be an integer from 0 through 3650");
  }
  return options;
}

function collectJsonFiles(directory) {
  if (!fs.existsSync(directory)) return [];
  const files = [];
  for (const entry of fs.readdirSync(directory, { withFileTypes: true })) {
    const candidate = path.join(directory, entry.name);
    if (entry.isDirectory()) files.push(...collectJsonFiles(candidate));
    else if (entry.isFile() && /^REF-\d{4}\.json$/.test(entry.name)) files.push(candidate);
  }
  return files;
}

function relativePath(file) {
  return path.relative(repositoryRoot, file).replaceAll(path.sep, "/");
}

function readEntries() {
  const sources = [
    ...collectJsonFiles(path.join(repositoryRoot, "book", "references")).map((file) => ({ file, scope: "canonical" })),
    ...collectJsonFiles(path.join(repositoryRoot, "drafts")).filter((file) => file.includes(`${path.sep}support${path.sep}references${path.sep}`)).map((file) => ({ file, scope: "staged" })),
  ].sort((left, right) => relativePath(left.file).localeCompare(relativePath(right.file)));

  return sources.map(({ file, scope }) => {
    const portablePath = relativePath(file);
    try {
      const record = JSON.parse(fs.readFileSync(file, "utf8"));
      if (`${record.id}.json` !== path.basename(file)) {
        return { path: portablePath, scope, record, preflightError: `filename does not match reference id ${String(record.id)}` };
      }
      return { path: portablePath, scope, record };
    } catch (error) {
      return { path: portablePath, scope, record: null, preflightError: `invalid JSON: ${error.message}` };
    }
  });
}

const options = parseArguments(process.argv.slice(2));
const entries = readEntries();
const result = evaluateReferenceFreshness(entries, options);

if (options.json) {
  console.log(JSON.stringify(result, null, 2));
} else {
  const summary = result.summary;
  console.log(`REFERENCE_FRESHNESS as_of=${result.asOf} warning_window_days=${result.warnDays}`);
  console.log(`SUMMARY records=${summary.records} canonical=${summary.canonical} staged=${summary.staged} current=${summary.current} due_soon=${summary.dueSoon} overdue=${summary.overdue} duplicate_url_groups=${summary.duplicateUrlGroups} errors=${summary.errors}`);
  for (const row of result.rows.filter((entry) => entry.status !== "current").slice(0, 25)) {
    console.log(`${row.status.toUpperCase()} ${row.id} review_after=${row.reviewAfter} days=${row.daysUntilReview} path=${row.path}`);
  }
  if (result.rows.filter((entry) => entry.status !== "current").length > 25) {
    console.log("NOTICE additional due-soon or overdue records omitted; rerun with --json for the complete result");
  }
  for (const error of result.errors) console.error(`ERROR ${error}`);
}

if (result.errors.length > 0 || (options.failOverdue && result.summary.overdue > 0)) {
  process.exitCode = 1;
} else if (!options.json) {
  console.log(`PASS reference freshness: ${result.summary.records} records are structurally reportable and ${result.summary.overdue} are overdue`);
}
