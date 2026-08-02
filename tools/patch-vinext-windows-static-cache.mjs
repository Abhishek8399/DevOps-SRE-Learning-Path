import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const scriptDirectory = path.dirname(fileURLToPath(import.meta.url));
const repositoryRoot = path.resolve(scriptDirectory, "..");
const vinextRoot = path.join(
  repositoryRoot,
  "learning-cockpit",
  "node_modules",
  "vinext",
);
const packagePath = path.join(vinextRoot, "package.json");
const cachePath = path.join(vinextRoot, "dist", "server", "static-file-cache.js");
const serverPath = path.join(vinextRoot, "dist", "server", "prod-server.js");
const supportedVersion = "0.0.50";

if (process.platform !== "win32") {
  console.log("vinext static-path compatibility patch: not required on this platform");
  process.exit(0);
}

if (!fs.existsSync(packagePath) || !fs.existsSync(cachePath) || !fs.existsSync(serverPath)) {
  throw new Error(
    "vinext static-path compatibility patch: dependency files are missing; run npm ci first",
  );
}

const packageMetadata = JSON.parse(fs.readFileSync(packagePath, "utf8"));
if (packageMetadata.version !== supportedVersion) {
  throw new Error(
    `vinext ${packageMetadata.version} static-path compatibility patch: only ${supportedVersion} is reviewed; refusing an unsafe patch`,
  );
}

const cacheOriginal = "relativePath: path.relative(base, batch[j]),";
const cacheReplacement =
  'relativePath: path.relative(base, batch[j]).split(path.sep).join("/"),';
const serverOriginal = [
  "\t\tconst entry = cache.lookup(lookupPath);",
  "\t\tif (!entry) return false;",
].join("\n");
const serverFilesystemFallback = [
  "\t\tconst entry = cache.lookup(lookupPath);",
  "\t\tif (!entry) {",
  "\t\t\tif (process.platform === \"win32\") return tryServeStatic(req, res, clientDir, pathname, compress, void 0, extraHeaders, statusCode);",
  "\t\t\treturn false;",
  "\t\t}",
].join("\n");
const serverReplacement = [
  "\t\tlet entry = cache.lookup(lookupPath);",
  "\t\tif (!entry && process.platform === \"win32\" && lookupPath.indexOf(\"/\", 1) !== -1) {",
  "\t\t\tentry = cache.lookup(\"/\" + lookupPath.slice(1).split(\"/\").join(path.sep));",
  "\t\t}",
  "\t\tif (!entry) return false;",
].join("\n");
const patchContracts = [
  {
    label: "cache path normalization",
    target: cachePath,
    original: cacheOriginal,
    replacement: cacheReplacement,
  },
  {
    label: "cache-only legacy-key fallback",
    target: serverPath,
    original: serverOriginal,
    replacement: serverReplacement,
    legacyOriginals: [serverFilesystemFallback],
  },
];

const plannedPatches = patchContracts.map((contract) => {
  const source = fs.readFileSync(contract.target, "utf8");
  if (source.includes(contract.replacement)) {
    return { ...contract, source, changed: false };
  }
  const acceptedOriginal = [contract.original, ...(contract.legacyOriginals ?? [])]
    .find((candidate) => source.includes(candidate));
  if (!acceptedOriginal) {
    throw new Error(
      `vinext ${packageMetadata.version} static-path compatibility patch: ${contract.label} contract was not found; refusing an unsafe patch`,
    );
  }
  return {
    ...contract,
    source: source.replace(acceptedOriginal, contract.replacement),
    changed: true,
  };
});

for (const patch of plannedPatches.filter(({ changed }) => changed)) {
  const temporaryPath = `${patch.target}.${process.pid}.tmp`;
  try {
    fs.writeFileSync(temporaryPath, patch.source, "utf8");
    fs.renameSync(temporaryPath, patch.target);
  } finally {
    if (fs.existsSync(temporaryPath)) fs.unlinkSync(temporaryPath);
  }
}

const changedLabels = plannedPatches
  .filter(({ changed }) => changed)
  .map(({ label }) => label);
console.log(
  changedLabels.length > 0
    ? `vinext ${packageMetadata.version} static-path compatibility patch: applied ${changedLabels.join(", ")}`
    : `vinext ${packageMetadata.version} static-path compatibility patch: already applied`,
);
