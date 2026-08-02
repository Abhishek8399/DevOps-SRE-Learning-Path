#!/usr/bin/env node

import { existsSync, lstatSync, readFileSync, readdirSync, realpathSync, statSync } from "node:fs";
import { dirname, extname, isAbsolute, join, relative, resolve, sep } from "node:path";
import { fileURLToPath } from "node:url";
import { validateRepositoryStructuredContent } from "./lib/structured-content.mjs";

const scriptDirectory = dirname(fileURLToPath(import.meta.url));
const repositoryRoot = resolve(scriptDirectory, "..");
const repositoryRootReal = realpathSync(repositoryRoot);
const excludedDirectories = new Set([".git", "node_modules", "dist", ".next"]);
const requiredMemoryFiles = [
  "BOOK_SPEC.md",
  "MASTER_PLAN.md",
  "CONTENT_MATRIX.md",
  "PROGRESS.md",
  "DECISIONS.md",
  "VERIFICATION.md",
];
const stableIdPattern = /^[A-Z][A-Z0-9]{1,15}-\d{3}$/;

const errors = [];
const metrics = {
  rootMemoryFiles: 0,
  markdownFiles: 0,
  localLinks: 0,
  explicitAnchorLinks: 0,
  generatedHeadingAnchors: 0,
  curriculumIds: 0,
  mappedRequirements: null,
  structuredSchemaFiles: 0,
  structuredLessons: 0,
  structuredAssessments: 0,
  structuredReferences: 0,
  structuredLegacyLessons: 0,
};

function repositoryPath(absolutePath) {
  const pathFromRoot = relative(repositoryRoot, absolutePath);
  return pathFromRoot === "" ? "." : pathFromRoot.split(sep).join("/");
}

function addError(filePath, line, message) {
  const displayPath = isAbsolute(filePath) ? repositoryPath(filePath) : filePath;
  errors.push({ file: displayPath, line: Math.max(1, line ?? 1), message });
}

function pathIsWithin(root, candidate) {
  const pathFromRoot = relative(root, candidate);
  return pathFromRoot === "" || (!pathFromRoot.startsWith(`..${sep}`) && pathFromRoot !== "..");
}

function collectMarkdownFiles(directory) {
  const files = [];
  const entries = readdirSync(directory, { withFileTypes: true }).sort((left, right) =>
    left.name.localeCompare(right.name),
  );
  for (const entry of entries) {
    if (entry.isDirectory() && excludedDirectories.has(entry.name)) continue;
    const entryPath = join(directory, entry.name);
    if (entry.isDirectory()) {
      files.push(...collectMarkdownFiles(entryPath));
    } else if (entry.isFile() && extname(entry.name).toLowerCase() === ".md") {
      files.push(entryPath);
    }
  }
  return files;
}

function replaceRangeWithSpaces(value, start, end) {
  return value.slice(0, start) + " ".repeat(end - start) + value.slice(end);
}

function maskInlineCode(line) {
  let masked = line;
  let cursor = 0;
  while (cursor < line.length) {
    const opening = line.indexOf("`", cursor);
    if (opening === -1) break;
    let markerLength = 1;
    while (line[opening + markerLength] === "`") markerLength += 1;
    const marker = "`".repeat(markerLength);
    const closing = line.indexOf(marker, opening + markerLength);
    if (closing === -1) {
      cursor = opening + markerLength;
      continue;
    }
    const end = closing + markerLength;
    masked = replaceRangeWithSpaces(masked, opening, end);
    cursor = end;
  }
  return masked;
}

function maskHtmlComments(line, state) {
  let masked = line;
  let cursor = 0;
  while (cursor < line.length) {
    if (state.open) {
      const closing = line.indexOf("-->", cursor);
      if (closing === -1) return { line: " ".repeat(line.length), open: true };
      masked = replaceRangeWithSpaces(masked, cursor, closing + 3);
      cursor = closing + 3;
      state.open = false;
      continue;
    }
    const opening = line.indexOf("<!--", cursor);
    if (opening === -1) break;
    const closing = line.indexOf("-->", opening + 4);
    if (closing === -1) {
      masked = replaceRangeWithSpaces(masked, opening, line.length);
      state.open = true;
      break;
    }
    masked = replaceRangeWithSpaces(masked, opening, closing + 3);
    cursor = closing + 3;
  }
  return { line: masked, open: state.open };
}

function parseFenceOpening(line) {
  const marker = line.match(/^\s{0,3}(`{3,}|~{3,})(.*)$/);
  if (!marker) return null;
  const character = marker[1][0];
  if (character === "`" && marker[2].includes("`")) return null;
  return { character, length: marker[1].length };
}

function prepareMarkdownLines(text) {
  const originalLines = text.split(/\r?\n/);
  const headingLines = [];
  const linkLines = [];
  const commentState = { open: false };
  let fence = null;
  let jsonFrontMatterEnd = -1;

  if (originalLines[0]?.trim() === "---"
    && originalLines[1]?.trimStart().startsWith("{")) {
    jsonFrontMatterEnd = originalLines.findIndex((line, index) =>
      index > 1 && line.trim() === "---");
  }

  for (let lineIndex = 0; lineIndex < originalLines.length; lineIndex += 1) {
    const originalLine = originalLines[lineIndex];
    if (jsonFrontMatterEnd >= 0 && lineIndex <= jsonFrontMatterEnd) {
      headingLines.push(" ".repeat(originalLine.length));
      linkLines.push(" ".repeat(originalLine.length));
      continue;
    }
    const fenceMatch = parseFenceOpening(originalLine);
    if (fence) {
      headingLines.push(" ".repeat(originalLine.length));
      linkLines.push(" ".repeat(originalLine.length));
      const closingFence = originalLine.match(/^\s{0,3}(`{3,}|~{3,})\s*$/);
      if (closingFence && closingFence[1][0] === fence.character
        && closingFence[1].length >= fence.length) {
        fence = null;
      }
      continue;
    }
    if (fenceMatch) {
      fence = fenceMatch;
      headingLines.push(" ".repeat(originalLine.length));
      linkLines.push(" ".repeat(originalLine.length));
      continue;
    }
    const commentResult = maskHtmlComments(originalLine, commentState);
    commentState.open = commentResult.open;
    headingLines.push(commentResult.line);
    linkLines.push(maskInlineCode(commentResult.line));
  }
  return { originalLines, headingLines, linkLines };
}

function decodeHtmlEntities(value) {
  const named = new Map([
    ["amp", "&"], ["apos", "'"], ["gt", ">"],
    ["lt", "<"], ["nbsp", " "], ["quot", '"'],
  ]);
  return value.replace(/&(#x[\da-f]+|#\d+|[a-z]+);/gi, (match, entity) => {
    if (entity[0] === "#") {
      const hexadecimal = entity[1]?.toLowerCase() === "x";
      const number = Number.parseInt(entity.slice(hexadecimal ? 2 : 1), hexadecimal ? 16 : 10);
      try {
        return Number.isFinite(number) ? String.fromCodePoint(number) : match;
      } catch {
        return match;
      }
    }
    return named.get(entity.toLowerCase()) ?? match;
  });
}

function headingSlugBase(rawHeading) {
  const withoutFormatting = rawHeading
    .replace(/!\[([^\]]*)\]\([^)]*\)/g, "$1")
    .replace(/\[([^\]]+)\]\([^)]*\)/g, "$1")
    .replace(/<[^>]*>/g, "")
    .replace(/[\x60*_~]/g, "");
  return decodeHtmlEntities(withoutFormatting).trim().toLocaleLowerCase("en-US")
    .replace(/[^\p{L}\p{N}\p{M}\s_-]/gu, "").replace(/\s/g, "-");
}

function collectAnchors(filePath, prepared) {
  const anchors = new Set();
  const generatedCounts = new Map();
  const explicitLocations = new Map();

  function registerHeading(rawHeading, line) {
    const base = headingSlugBase(rawHeading);
    if (!base) {
      addError(filePath, line, "heading does not generate a usable anchor");
      return;
    }
    const prior = generatedCounts.get(base);
    const duplicateIndex = prior ? prior.count : 0;
    if (prior) {
      addError(filePath, line,
        `duplicate generated heading anchor "#${base}" (first generated at line ${prior.line})`);
      prior.count += 1;
    } else {
      generatedCounts.set(base, { count: 1, line });
    }
    anchors.add(duplicateIndex === 0 ? base : `${base}-${duplicateIndex}`);
    metrics.generatedHeadingAnchors += 1;
  }

  for (let index = 0; index < prepared.headingLines.length; index += 1) {
    const line = prepared.headingLines[index];
    const atxHeading = line.match(/^\s{0,3}#{1,6}(?:[ \t]+|$)(.*)$/);
    if (atxHeading) {
      registerHeading(atxHeading[1].replace(/[ \t]+#+[ \t]*$/, "").trim(), index + 1);
    } else if (index > 0 && /^\s{0,3}(?:=+|-+)\s*$/.test(line)
      && prepared.headingLines[index - 1].trim() !== "") {
      registerHeading(prepared.headingLines[index - 1].trim(), index);
    }

    const htmlAnchor = /<[a-z][^>]*\s(?:id|name)\s*=\s*(?:"([^"]+)"|'([^']+)'|([^\s>]+))[^>]*>/gi;
    for (const match of line.matchAll(htmlAnchor)) {
      const anchor = decodeHtmlEntities(match[1] ?? match[2] ?? match[3]);
      const firstLine = explicitLocations.get(anchor);
      if (firstLine) {
        addError(filePath, index + 1,
          `duplicate explicit HTML anchor "#${anchor}" (first defined at line ${firstLine})`);
      } else {
        explicitLocations.set(anchor, index + 1);
        anchors.add(anchor);
      }
    }
  }
  return anchors;
}

function isEscaped(value, index) {
  let backslashes = 0;
  for (let cursor = index - 1; cursor >= 0 && value[cursor].codePointAt(0) === 92; cursor -= 1) {
    backslashes += 1;
  }
  return backslashes % 2 === 1;
}

function lineForOffset(value, offset) {
  let line = 1;
  for (let index = 0; index < offset; index += 1) {
    if (value[index] === "\n") line += 1;
  }
  return line;
}

function findClosingBracket(value, opening) {
  let depth = 1;
  for (let index = opening + 1; index < value.length; index += 1) {
    if (isEscaped(value, index)) continue;
    if (value[index] === "[") depth += 1;
    else if (value[index] === "]") {
      depth -= 1;
      if (depth === 0) return index;
    }
  }
  return -1;
}

function findClosingParenthesis(value, opening) {
  let depth = 1;
  let quote = null;
  let inAngleDestination = false;
  let titleMayStart = false;
  for (let index = opening + 1; index < value.length; index += 1) {
    const character = value[index];
    if (isEscaped(value, index)) continue;
    if (quote) {
      if (character === quote) quote = null;
      continue;
    }
    if (inAngleDestination) {
      if (character === ">") inAngleDestination = false;
      continue;
    }
    if (character === "<" && depth === 1) {
      inAngleDestination = true;
      titleMayStart = false;
    } else if (titleMayStart && (character === '"' || character === "'")) {
      quote = character;
      titleMayStart = false;
    } else if (character === "(") {
      depth += 1;
      titleMayStart = false;
    } else if (character === ")") {
      depth -= 1;
      if (depth === 0) return index;
      titleMayStart = false;
    } else if (depth === 1 && /\s/.test(character)) {
      titleMayStart = true;
    } else if (!/\s/.test(character)) {
      titleMayStart = false;
    }
  }
  return -1;
}

function isValidLinkTitle(value) {
  return /^"(?:[^"\\]|\\.)*"$/s.test(value)
    || /^'(?:[^'\\]|\\.)*'$/s.test(value)
    || /^\((?:[^)\\]|\\.)*\)$/s.test(value);
}

function splitDestination(rawContents) {
  const contents = rawContents.trim();
  if (!contents) return { error: "empty Markdown link destination" };
  if (contents.startsWith("<")) {
    const closing = contents.indexOf(">");
    if (closing === -1) return { error: "angle-bracket link destination is missing '>'" };
    const destination = contents.slice(1, closing);
    const title = contents.slice(closing + 1).trim();
    if (title && !isValidLinkTitle(title)) {
      return { error: "link title after angle-bracket destination is malformed" };
    }
    return { destination };
  }

  let depth = 0;
  let boundary = contents.length;
  for (let index = 0; index < contents.length; index += 1) {
    if (isEscaped(contents, index)) continue;
    if (contents[index] === "(") depth += 1;
    else if (contents[index] === ")" && depth > 0) depth -= 1;
    else if (/\s/.test(contents[index]) && depth === 0) {
      boundary = index;
      break;
    }
  }
  const destination = contents.slice(0, boundary);
  const title = contents.slice(boundary).trim();
  if (!destination) return { error: "empty Markdown link destination" };
  if (title && !isValidLinkTitle(title)) {
    return { error: "unescaped whitespace in link destination; wrap the path in '<...>' or escape spaces" };
  }
  return { destination };
}

function unescapeMarkdownDestination(value) {
  return value.replace(/\\([\s\S])/g, (match, character) => {
    const codePoint = character.codePointAt(0);
    const punctuation = (codePoint >= 0x21 && codePoint <= 0x2f)
      || (codePoint >= 0x3a && codePoint <= 0x40)
      || (codePoint >= 0x5b && codePoint <= 0x60)
      || (codePoint >= 0x7b && codePoint <= 0x7e);
    return character === " " || punctuation ? character : match;
  });
}

function decodeUriPart(value) {
  try {
    return { value: decodeURIComponent(value) };
  } catch {
    return { error: `invalid percent-encoding in link destination "${value}"` };
  }
}

function exactCaseMismatch(absolutePath) {
  const pathFromRoot = relative(repositoryRoot, absolutePath);
  let cursor = repositoryRoot;
  for (const component of pathFromRoot.split(sep).filter(Boolean)) {
    const entries = readdirSync(cursor);
    if (!entries.includes(component)) {
      const actual = entries.find((entry) =>
        entry.toLocaleLowerCase("en-US") === component.toLocaleLowerCase("en-US"));
      if (actual) return { requested: component, actual };
      return null;
    }
    cursor = join(cursor, component);
  }
  return null;
}

function validateLocalDestination(sourceFile, line, rawDestination, anchorIndex) {
  const destination = unescapeMarkdownDestination(rawDestination.trim());
  if (!destination) {
    addError(sourceFile, line, "empty Markdown link destination");
    return;
  }
  if (/^[a-z]:/i.test(destination)) {
    addError(sourceFile, line, `non-portable absolute Windows link "${destination}"`);
    return;
  }
  if (/^file:/i.test(destination)) {
    addError(sourceFile, line, `non-portable file URI "${destination}"`);
    return;
  }
  if (/^[a-z][a-z\d+.-]*:/i.test(destination) || destination.startsWith("//")) return;
  if (destination.startsWith("/")) return;
  if (destination.includes(String.fromCharCode(92))) {
    addError(sourceFile, line, `local Markdown links must use '/' separators: "${destination}"`);
    return;
  }

  const hashIndex = destination.indexOf("#");
  const hasExplicitAnchor = hashIndex !== -1;
  const beforeAnchor = hasExplicitAnchor ? destination.slice(0, hashIndex) : destination;
  const rawAnchor = hasExplicitAnchor ? destination.slice(hashIndex + 1) : null;
  const queryIndex = beforeAnchor.indexOf("?");
  const rawPath = queryIndex === -1 ? beforeAnchor : beforeAnchor.slice(0, queryIndex);
  const decodedPath = decodeUriPart(rawPath);
  if (decodedPath.error) {
    addError(sourceFile, line, decodedPath.error);
    return;
  }
  if (/^[a-z]:/i.test(decodedPath.value) || decodedPath.value.includes(String.fromCharCode(92))) {
    addError(sourceFile, line, `decoded local link is not portable: "${decodedPath.value}"`);
    return;
  }
  const decodedAnchor = hasExplicitAnchor ? decodeUriPart(rawAnchor) : null;
  if (decodedAnchor?.error) {
    addError(sourceFile, line, decodedAnchor.error);
    return;
  }
  if (hasExplicitAnchor && decodedAnchor.value === "") {
    addError(sourceFile, line, "explicit Markdown anchor is empty");
    return;
  }

  const targetPath = decodedPath.value ? resolve(dirname(sourceFile), decodedPath.value) : sourceFile;
  metrics.localLinks += 1;
  if (hasExplicitAnchor) metrics.explicitAnchorLinks += 1;
  if (!pathIsWithin(repositoryRoot, targetPath)) {
    addError(sourceFile, line, `relative link escapes the repository: "${destination}"`);
    return;
  }
  if (!existsSync(targetPath)) {
    addError(sourceFile, line, `broken relative link; target does not exist: "${rawPath || destination}"`);
    return;
  }

  const targetRealPath = realpathSync(targetPath);
  if (!pathIsWithin(repositoryRootReal, targetRealPath)) {
    addError(sourceFile, line,
      `relative link resolves outside the repository through a symlink: "${destination}"`);
    return;
  }
  const caseMismatch = exactCaseMismatch(targetPath);
  if (caseMismatch) {
    addError(sourceFile, line,
      `link path casing is not portable: requested "${caseMismatch.requested}", actual "${caseMismatch.actual}"`);
    return;
  }
  if (!hasExplicitAnchor) return;

  let markdownTarget = targetPath;
  if (statSync(targetPath).isDirectory()) markdownTarget = join(targetPath, "README.md");
  const targetAnchors = anchorIndex.get(resolve(markdownTarget));
  if (!targetAnchors) {
    addError(sourceFile, line,
      `cannot validate anchor "#${decodedAnchor.value}" because target is not scanned Markdown: "${rawPath}"`);
    return;
  }
  if (!targetAnchors.has(decodedAnchor.value)) {
    addError(sourceFile, line,
      `broken explicit anchor "#${decodedAnchor.value}" in ${repositoryPath(markdownTarget)}`);
  }
}

function validateLinks(filePath, prepared, anchorIndex) {
  const value = prepared.linkLines.join("\n");
  const parsedClosings = new Set();
  for (let index = 0; index < value.length; index += 1) {
    if (value[index] !== "[") continue;
    const escapedOpening = isEscaped(value, index);
    const closingBracket = findClosingBracket(value, index);
    if (closingBracket === -1 || value[closingBracket + 1] !== "(") continue;
    parsedClosings.add(closingBracket);
    if (escapedOpening) {
      index = closingBracket;
      continue;
    }
    const closingParenthesis = findClosingParenthesis(value, closingBracket + 1);
    const line = lineForOffset(value, index);
    if (closingParenthesis === -1) {
      addError(filePath, line, "malformed inline Markdown link; closing ')' is missing");
      index = closingBracket + 1;
      continue;
    }
    const parsed = splitDestination(value.slice(closingBracket + 2, closingParenthesis));
    if (parsed.error) addError(filePath, line, parsed.error);
    else validateLocalDestination(filePath, line, parsed.destination, anchorIndex);
    index = closingParenthesis;
  }

  for (let index = 0; index < value.length - 1; index += 1) {
    if (value[index] === "]" && value[index + 1] === "(" && !isEscaped(value, index)
      && !parsedClosings.has(index)) {
      addError(filePath, lineForOffset(value, index),
        "malformed inline Markdown link; opening '[' is missing");
    }
  }
  for (let index = 0; index < prepared.linkLines.length; index += 1) {
    const definition = prepared.linkLines[index].match(/^\s{0,3}\[[^\]]+\]:\s*(.*)$/);
    if (!definition) continue;
    const parsed = splitDestination(definition[1]);
    if (parsed.error) {
      addError(filePath, index + 1, `malformed reference-style Markdown link: ${parsed.error}`);
    } else {
      validateLocalDestination(filePath, index + 1, parsed.destination, anchorIndex);
    }
  }
}

function validateRequiredMemoryFiles() {
  for (const requiredFile of requiredMemoryFiles) {
    const absolutePath = join(repositoryRoot, requiredFile);
    if (!existsSync(absolutePath) || !lstatSync(absolutePath).isFile()) {
      addError(requiredFile, 1, "required root project-memory file is missing");
    } else {
      metrics.rootMemoryFiles += 1;
    }
  }
}

function splitMarkdownTableRow(line) {
  const trimmed = line.trim();
  if (!trimmed.startsWith("|") || !trimmed.endsWith("|")) return null;
  return trimmed.slice(1, -1).split(/(?<!\\)\|/)
    .map((cell) => cell.trim().replace(/\\\|/g, "|"));
}

function validateCurriculumMatrix() {
  const matrixPath = join(repositoryRoot, "CONTENT_MATRIX.md");
  if (!existsSync(matrixPath)) return;
  const lines = readFileSync(matrixPath, "utf8").split(/\r?\n/);
  const firstDefinition = new Map();
  for (let index = 0; index < lines.length; index += 1) {
    const cells = splitMarkdownTableRow(lines[index]);
    if (!cells || !stableIdPattern.test(cells[0])) continue;
    const id = cells[0];
    const firstLine = firstDefinition.get(id);
    if (firstLine) {
      addError(matrixPath, index + 1,
        `duplicate stable curriculum ID "${id}" (first defined at line ${firstLine})`);
    } else {
      firstDefinition.set(id, index + 1);
    }
  }
  metrics.curriculumIds = firstDefinition.size;

  const coverageHeadingIndex = lines.findIndex((line) =>
    /^#{1,6}\s+.*coverage audit.*46 required areas/i.test(line));
  if (coverageHeadingIndex === -1) return;
  const headingLevel = lines[coverageHeadingIndex].match(/^#+/)[0].length;
  const mapped = new Set();
  let recognizedCoverageTable = false;

  for (let index = coverageHeadingIndex + 1; index < lines.length; index += 1) {
    const nextHeading = lines[index].match(/^(#{1,6})\s+/);
    if (nextHeading && nextHeading[1].length <= headingLevel) break;
    const cells = splitMarkdownTableRow(lines[index]);
    if (!cells) continue;
    if (/^requirements?$/i.test(cells[0])) {
      recognizedCoverageTable = true;
      continue;
    }
    const requirementSpec = cells[0].replace(/[\x60*_]/g, "").trim();
    if (!/\d/.test(requirementSpec)) continue;
    const tokens = requirementSpec.split(/\s*(?:,|;|&|\band\b)\s*/i).filter(Boolean);
    let rowRecognized = false;
    for (const token of tokens) {
      const rangeMatch = token.match(/^(\d{1,2})\s*(?:\.{2}|[-\u2013\u2014])\s*(\d{1,2})$/);
      const singleMatch = token.match(/^(\d{1,2})$/);
      if (rangeMatch) {
        const start = Number(rangeMatch[1]);
        const end = Number(rangeMatch[2]);
        if (start <= end) {
          for (let requirement = start; requirement <= end; requirement += 1) {
            if (requirement >= 1 && requirement <= 46) mapped.add(requirement);
          }
          rowRecognized = true;
        }
      } else if (singleMatch) {
        const requirement = Number(singleMatch[1]);
        if (requirement >= 1 && requirement <= 46) {
          mapped.add(requirement);
          rowRecognized = true;
        }
      }
    }
    recognizedCoverageTable ||= rowRecognized;
  }

  if (!recognizedCoverageTable) return;
  metrics.mappedRequirements = mapped.size;
  for (let requirement = 1; requirement <= 46; requirement += 1) {
    if (!mapped.has(requirement)) {
      addError(matrixPath, coverageHeadingIndex + 1,
        `requirement ${requirement} is not explicitly mapped in the coverage audit`);
    }
  }
}

function printResults() {
  errors.sort((left, right) => left.file.localeCompare(right.file)
    || left.line - right.line || left.message.localeCompare(right.message));
  const requirementSummary = metrics.mappedRequirements === null
    ? "not-audited(format-not-detected)" : `${metrics.mappedRequirements}/46`;
  const summary = `root-memory=${metrics.rootMemoryFiles}/${requiredMemoryFiles.length} `
    + `markdown=${metrics.markdownFiles} local-links=${metrics.localLinks} `
    + `explicit-anchors=${metrics.explicitAnchorLinks} `
    + `heading-anchors=${metrics.generatedHeadingAnchors} `
    + `curriculum-ids=${metrics.curriculumIds} requirements=${requirementSummary}`;
  const structuredSummary = `schemas=${metrics.structuredSchemaFiles}/3 lessons=${metrics.structuredLessons} `
    + `assessments=${metrics.structuredAssessments} references=${metrics.structuredReferences} `
    + `legacy-reservations=${metrics.structuredLegacyLessons}`;

  if (errors.length > 0) {
    console.error(`FAIL content validation: ${errors.length} error${errors.length === 1 ? "" : "s"}`);
    for (const error of errors) {
      console.error(`${error.file}:${error.line}: ERROR ${error.message}`);
    }
    console.error(`SUMMARY ${summary} structured={${structuredSummary}}`);
  } else {
    console.log(`PASS content validation ${summary} structured={${structuredSummary}}`);
  }
}

validateRequiredMemoryFiles();
const markdownFiles = collectMarkdownFiles(repositoryRoot);
metrics.markdownFiles = markdownFiles.length;
const documents = new Map();
const anchorIndex = new Map();
for (const markdownFile of markdownFiles) {
  const prepared = prepareMarkdownLines(readFileSync(markdownFile, "utf8"));
  documents.set(markdownFile, prepared);
  anchorIndex.set(resolve(markdownFile), collectAnchors(markdownFile, prepared));
}
for (const [markdownFile, prepared] of documents) {
  validateLinks(markdownFile, prepared, anchorIndex);
}
validateCurriculumMatrix();
const structured = validateRepositoryStructuredContent(repositoryRoot);
metrics.structuredSchemaFiles = structured.metrics.schemaFiles;
metrics.structuredLessons = structured.metrics.lessons;
metrics.structuredAssessments = structured.metrics.assessments;
metrics.structuredReferences = structured.metrics.references;
metrics.structuredLegacyLessons = structured.metrics.legacyLessons;
for (const structuredIssue of structured.issues) {
  addError(structuredIssue.file ?? "book/schema", structuredIssue.line,
    `[${structuredIssue.code}] ${structuredIssue.path}: ${structuredIssue.message}`);
}
printResults();
process.exitCode = errors.length === 0 ? 0 : 1;
