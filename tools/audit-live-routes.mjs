import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const repositoryRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const volumeRoot = path.join(repositoryRoot, "book", "volumes");
const careerRoot = path.join(repositoryRoot, "career");
const requestedBase = process.argv[2] ?? "http://127.0.0.1:3000";
const base = new URL(requestedBase);
if (!['127.0.0.1', 'localhost', '[::1]'].includes(base.hostname) || !['http:', 'https:'].includes(base.protocol)) {
  throw new Error(`live-route audit refuses non-loopback base URL: ${base.origin}`);
}

function walk(root) {
  return fs.readdirSync(root, { withFileTypes: true }).flatMap((entry) => {
    const absolute = path.join(root, entry.name);
    if (entry.isDirectory()) return walk(absolute);
    return entry.isFile() && entry.name === "lesson.md" ? [absolute] : [];
  });
}

function lessonRoute(file) {
  const source = fs.readFileSync(file, "utf8");
  const match = source.match(/^---\r?\n([\s\S]*?)\r?\n---\r?\n/);
  if (!match) throw new Error(`${path.relative(repositoryRoot, file)}: missing JSON front matter`);
  return JSON.parse(match[1]).route;
}

const lessons = walk(volumeRoot).map(lessonRoute);
const careerPrimers = fs.readdirSync(careerRoot, { withFileTypes: true })
  .filter((entry) => entry.isFile() && entry.name.endsWith("-primer.md"))
  .map((entry) => `/career/${entry.name.slice(0, -3)}`);
const fixedRoutes = [
  "/", "/book", "/book/start", "/book/linux", "/book/connectivity",
  "/book/engineering", "/book/reliability", "/book/infrastructure",
  "/book/state", "/book/ai", "/book/security", "/book/privatecloud",
  "/book/architecture", "/book/capstones", "/career", "/drafts",
  "/my-learning", "/practice/interview", "/practice/storage", "/search",
];
const targets = [...new Set([...fixedRoutes, ...lessons, ...careerPrimers])];
const failures = [];

for (let index = 0; index < targets.length; index += 8) {
  const batch = targets.slice(index, index + 8);
  await Promise.all(batch.map(async (route) => {
    try {
      const response = await fetch(new URL(route, base), { signal: AbortSignal.timeout(20_000) });
      const body = await response.text();
      if (response.status !== 200) failures.push(`${route}: expected 200, found ${response.status}`);
      if (/Transform failed|Failed to load url/.test(body)) failures.push(`${route}: transform-error marker present`);
    } catch (error) {
      failures.push(`${route}: ${error instanceof Error ? error.message : String(error)}`);
    }
  }));
}

const invalidRoute = "/book/linux/not-a-real-lesson";
const invalidResponse = await fetch(new URL(invalidRoute, base), { signal: AbortSignal.timeout(20_000) });
if (invalidResponse.status !== 404) failures.push(`${invalidRoute}: expected 404, found ${invalidResponse.status}`);

console.log(`LIVE_ROUTE_AUDIT base=${base.origin} routes=${targets.length} lessons=${lessons.length} career_primers=${careerPrimers.length} invalid_status=${invalidResponse.status} failures=${failures.length}`);
if (failures.length > 0) {
  for (const failure of failures) console.error(`LIVE_ROUTE_AUDIT ${failure}`);
  console.error("FAIL live route audit");
  process.exitCode = 1;
} else {
  console.log("PASS live route audit: every canonical lesson and primary application surface returned 200, the invalid lesson returned 404, and no transform-error marker was rendered");
}
