import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const assetsRoot = path.join(root, "learning-cockpit", "dist", "client", "assets");
const budgets = Object.freeze({
  javaScriptBytes: 512 * 1024,
  cssBytes: 256 * 1024,
  totalBytes: 768 * 1024,
  assetCount: 80,
});

function walk(directory) {
  return fs.readdirSync(directory, { withFileTypes: true }).flatMap((entry) => {
    const full = path.join(directory, entry.name);
    return entry.isDirectory() ? walk(full) : [full];
  });
}

function size(files) {
  return files.reduce((sum, file) => sum + fs.statSync(file).size, 0);
}

function kib(bytes) {
  return `${(bytes / 1024).toFixed(1)} KiB`;
}

if (!fs.existsSync(assetsRoot)) {
  console.error("FAIL web budget: client build assets are missing; run npm run build first");
  process.exitCode = 1;
} else {
  const files = walk(assetsRoot);
  const jsFiles = files.filter((file) => path.extname(file) === ".js");
  const cssFiles = files.filter((file) => path.extname(file) === ".css");
  const metrics = Object.freeze({
    javaScriptBytes: size(jsFiles),
    cssBytes: size(cssFiles),
    totalBytes: size(files),
    assetCount: files.length,
  });
  const failures = Object.entries(budgets)
    .filter(([name, limit]) => metrics[name] > limit)
    .map(([name, limit]) => `${name}=${metrics[name]} exceeds ${limit}`);

  if (failures.length) {
    console.error(`FAIL web budget assets=${metrics.assetCount} js=${kib(metrics.javaScriptBytes)} css=${kib(metrics.cssBytes)} total=${kib(metrics.totalBytes)}`);
    failures.forEach((failure) => console.error(failure));
    process.exitCode = 1;
  } else {
    console.log(`PASS web budget assets=${metrics.assetCount}/${budgets.assetCount} js=${kib(metrics.javaScriptBytes)}/${kib(budgets.javaScriptBytes)} css=${kib(metrics.cssBytes)}/${kib(budgets.cssBytes)} total=${kib(metrics.totalBytes)}/${kib(budgets.totalBytes)}`);
  }
}
