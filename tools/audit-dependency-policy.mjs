import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const repositoryRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const packagePath = path.join(repositoryRoot, "learning-cockpit", "package.json");
const lockPath = path.join(repositoryRoot, "learning-cockpit", "package-lock.json");
const manifest = JSON.parse(fs.readFileSync(packagePath, "utf8"));
const lock = JSON.parse(fs.readFileSync(lockPath, "utf8"));
const issues = [];

const acceptedLicenses = new Set([
  "0BSD", "Apache-2.0", "Apache-2.0 AND LGPL-3.0-or-later",
  "Apache-2.0 AND LGPL-3.0-or-later AND MIT", "BSD-2-Clause",
  "BSD-3-Clause", "BlueOak-1.0.0", "CC-BY-4.0", "CC0-1.0", "ISC",
  "LGPL-3.0-or-later", "MIT", "MIT OR Apache-2.0", "MPL-2.0", "Python-2.0",
]);
const acceptedInstallScripts = new Set([
  "node_modules/fsevents",
  "node_modules/sharp",
  "node_modules/unrs-resolver",
  "node_modules/workerd",
  "node_modules/wrangler/node_modules/esbuild",
]);

if (lock.lockfileVersion !== 3) issues.push(`expected lockfileVersion 3, found ${lock.lockfileVersion}`);
const rootLock = lock.packages?.[""];
if (!rootLock) issues.push("package-lock root package is missing");

for (const dependencyGroup of ["dependencies", "devDependencies"]) {
  for (const [name, version] of Object.entries(manifest[dependencyGroup] ?? {})) {
    if (!/^\d+\.\d+\.\d+(?:-[0-9A-Za-z.-]+)?$/.test(version)) {
      issues.push(`${dependencyGroup}.${name}: version must be exact, found ${version}`);
    }
    if (rootLock?.[dependencyGroup]?.[name] !== version) {
      issues.push(`${dependencyGroup}.${name}: package.json and package-lock root disagree`);
    }
  }
}

const packages = Object.entries(lock.packages ?? {}).filter(([name]) => name !== "");
const licenses = new Set();
const installScripts = [];
for (const [name, record] of packages) {
  if (typeof record.version !== "string" || record.version.length === 0) {
    issues.push(`${name}: missing locked version`);
  }
  if (typeof record.license !== "string" || record.license.length === 0) {
    issues.push(`${name}: missing declared license`);
  } else {
    licenses.add(record.license);
    if (!acceptedLicenses.has(record.license)) issues.push(`${name}: unreviewed license ${record.license}`);
  }
  if (record.resolved && !record.resolved.startsWith("https://registry.npmjs.org/")) {
    issues.push(`${name}: package source is outside registry.npmjs.org`);
  }
  if (!record.link && !record.integrity && !record.inBundle) {
    issues.push(`${name}: missing integrity and is not declared bundled`);
  }
  if (record.hasInstallScript) installScripts.push(name);
}

for (const name of installScripts) {
  if (!acceptedInstallScripts.has(name)) issues.push(`${name}: unreviewed install script`);
}
for (const name of acceptedInstallScripts) {
  if (!installScripts.includes(name)) issues.push(`${name}: install-script allowlist is stale`);
}

console.log(`DEPENDENCY_POLICY packages=${packages.length} licenses=${licenses.size} install_scripts=${installScripts.length} issues=${issues.length}`);
console.log(`LICENSE_EXPRESSIONS ${[...licenses].sort().join(" | ")}`);
console.log(`INSTALL_SCRIPTS ${installScripts.sort().join(" | ")}`);
if (issues.length > 0) {
  for (const issue of issues) console.error(`DEPENDENCY_POLICY ${issue}`);
  console.error("FAIL dependency policy");
  process.exitCode = 1;
} else {
  console.log("PASS dependency policy: exact direct versions, registry sources, integrity/bundling, license expressions, and install-script inventory match the reviewed lockfile policy");
}
