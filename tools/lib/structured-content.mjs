import { createHash } from "node:crypto";
import { existsSync, lstatSync, readFileSync, readdirSync, realpathSync, statSync } from "node:fs";
import { basename, extname, isAbsolute, join, relative, resolve, sep } from "node:path";

export const REQUIRED_LESSON_HEADINGS = Object.freeze([
  "What you see and first thought",
  "Terms before commands",
  "Architecture map",
  "Request or state path",
  "Failure zoom",
  "Internals and state ownership",
  "Evidence table",
  "Command decoders",
  "Decision path",
  "Guided Ubuntu lab",
  "Production transfer",
  "Reliability, security, observability, capacity, and cost",
  "Traps and prevention",
  "Memory card and retrieval",
  "Complete answers",
  "Product-company interview",
  "Independent transfer and rubric",
  "References and review",
]);

const schemaNames = Object.freeze({
  lesson: "lesson.schema.json",
  assessment: "assessment.schema.json",
  reference: "reference.schema.json",
});
const stableIdPattern = /^[A-Z][A-Z0-9]{1,15}-[0-9]{3}$/;
const lessonIdPattern = /^LES-[0-9]{4}$/;
const publicLessonAliasPattern = /^V[0-9]{2}-L[0-9]{2,3}$/;
const slugPattern = /^[a-z0-9]+(?:-[a-z0-9]+)*$/;
const routePattern = /^\/book(?:\/[a-z0-9]+(?:-[a-z0-9]+)*){2,}$/;
const requiredLegacyLessonIds = Object.freeze([
  "LES-0001", "LES-0002", "LES-0003", "LES-0004", "LES-0005",
]);
const legacyMapFileName = "legacy-content-map.json";
const legacyIdentityBaselineSha256 =
  "f160ccff9ba35ec2ea808e2dbad5570b076688ebbf93cccf9e5d9344ff618046";
const schemaDocumentBaselineSha256 = Object.freeze({
  lesson: "ac78b459aa1d7bd0509b482c4fc30a8f65304792e78265b7ec649563cd99f9fe",
  assessment: "1eb11a7c61d371d1ae54a39ad7145bc5cc767da9a9d517941d3b5581bac5540d",
  reference: "6737b4398c0af66164fd7ee0425f5227b475ca7541bbc4ffbfab721f3d7febb6",
});
const assessmentAnswerFields = Object.freeze([
  "directAnswer", "foundation", "reasoningSteps", "seniorAnswer", "weakAnswer",
  "whyWeak", "evidence", "followUps",
]);
const independentTransferFields = Object.freeze([
  "deliverables", "evidenceRequirements", "reviewPolicy",
]);
const levelOrder = Object.freeze({
  foundation: 0,
  intermediate: 1,
  advanced: 2,
  expert: 3,
});
const artifactSuffixByField = Object.freeze({
  diagrams: "DIA",
  commands: "CMD",
  labs: "LAB",
  incidents: "INC",
});

// Structured lessons must live in the canonical volume declared by BOOK_SPEC.md
// and CONTENT_MATRIX.md. Legacy typed lessons are validated separately because
// their curriculum ownership is migrated only through an explicit compatibility audit.
const canonicalCurriculumVolumeByPrefix = Object.freeze({
  FND: "00-start-safely",
  DBG: "00-start-safely",
  DOC: "00-start-safely",
  LNX: "01-linux-systems",
  NET: "02-connectivity",
  SCM: "03-engineering-delivery",
  AUT: "03-engineering-delivery",
  BLD: "03-engineering-delivery",
  REL: "03-engineering-delivery",
  CI: "03-engineering-delivery",
  GITOPS: "03-engineering-delivery",
  CTR: "03-engineering-delivery",
  OBS: "04-reliability-operations",
  SRE: "04-reliability-operations",
  PERF: "04-reliability-operations",
  RES: "04-reliability-operations",
  DR: "04-reliability-operations",
  CHAOS: "04-reliability-operations",
  IAC: "05-infrastructure-platforms",
  TFM: "05-infrastructure-platforms",
  CFG: "05-infrastructure-platforms",
  K8S: "05-infrastructure-platforms",
  PLT: "05-infrastructure-platforms",
  DST: "06-state-distributed-systems",
});

function isPlainObject(value) {
  return value !== null && typeof value === "object" && !Array.isArray(value);
}

function valuesEqual(left, right) {
  return JSON.stringify(left) === JSON.stringify(right);
}

function displayPath(repositoryRoot, absolutePath) {
  const fromRoot = relative(repositoryRoot, absolutePath);
  return fromRoot.split(sep).join("/");
}

const supportedSchemaKeywords = new Set([
  "$schema",
  "$id",
  "$defs",
  "$ref",
  "title",
  "description",
  "type",
  "additionalProperties",
  "required",
  "properties",
  "const",
  "enum",
  "pattern",
  "minLength",
  "maxLength",
  "format",
  "minimum",
  "maximum",
  "minItems",
  "uniqueItems",
  "items",
]);
const schemaTypes = new Set([
  "array", "boolean", "integer", "null", "number", "object", "string",
]);
const schemaFormats = new Set(["date", "uri"]);

export function validateSchemaDocument(schema) {
  const issues = [];
  const activeRules = new WeakSet();

  function invalidValue(path, keyword, expected) {
    issues.push(issue("SCHEMA_KEYWORD_VALUE", `${path}.${keyword}`,
      `keyword "${keyword}" must be ${expected}`));
  }

  function walk(rule, path) {
    if (!isPlainObject(rule)) {
      issues.push(issue("SCHEMA_RULE_INVALID", path, "schema rule must be an object"));
      return;
    }
    if (activeRules.has(rule)) {
      issues.push(issue("SCHEMA_OBJECT_CYCLE", path,
        "schema document contains a cyclic JavaScript object"));
      return;
    }
    activeRules.add(rule);
    for (const key of Object.keys(rule)) {
      if (!supportedSchemaKeywords.has(key)) {
        issues.push(issue("SCHEMA_KEYWORD_UNSUPPORTED", `${path}.${key}`,
          `keyword "${key}" is not supported by the dependency-free validator`));
      }
    }
    if (Object.hasOwn(rule, "$ref")) {
      if (typeof rule.$ref !== "string" || !rule.$ref.startsWith("#/")) {
        invalidValue(path, "$ref", "a local JSON Pointer string beginning with #/");
      }
      const siblings = Object.keys(rule).filter((key) => key !== "$ref");
      if (siblings.length > 0) {
        issues.push(issue("SCHEMA_REF_SIBLING", path,
          `$ref rules cannot have sibling keywords: ${siblings.join(", ")}`));
      }
    }
    for (const key of ["$schema", "$id", "title", "description", "pattern"]) {
      if (Object.hasOwn(rule, key) && typeof rule[key] !== "string") {
        invalidValue(path, key, "a string");
      }
    }
    if (Object.hasOwn(rule, "type") && !schemaTypes.has(rule.type)) {
      invalidValue(path, "type", "one supported JSON type name");
    }
    if (Object.hasOwn(rule, "format") && !schemaFormats.has(rule.format)) {
      invalidValue(path, "format", "one of date or uri");
    }
    for (const key of ["$defs", "properties"]) {
      if (Object.hasOwn(rule, key) && !isPlainObject(rule[key])) {
        invalidValue(path, key, "an object of schema rules");
      }
    }
    if (Object.hasOwn(rule, "required")
      && (!Array.isArray(rule.required)
        || rule.required.some((key) => typeof key !== "string" || key.length === 0)
        || new Set(rule.required).size !== rule.required.length)) {
      invalidValue(path, "required", "an array of unique non-empty strings");
    }
    if (Object.hasOwn(rule, "enum")
      && (!Array.isArray(rule.enum) || rule.enum.length === 0
        || new Set(rule.enum.map((value) => JSON.stringify(value))).size !== rule.enum.length)) {
      invalidValue(path, "enum", "a non-empty array of unique JSON values");
    }
    if (Object.hasOwn(rule, "additionalProperties")
      && typeof rule.additionalProperties !== "boolean"
      && !isPlainObject(rule.additionalProperties)) {
      invalidValue(path, "additionalProperties", "a boolean or schema rule");
    }
    if (Object.hasOwn(rule, "items") && !isPlainObject(rule.items)) {
      invalidValue(path, "items", "a schema rule object");
    }
    for (const key of ["minLength", "maxLength", "minItems"]) {
      if (Object.hasOwn(rule, key)
        && (!Number.isInteger(rule[key]) || rule[key] < 0)) {
        invalidValue(path, key, "a non-negative integer");
      }
    }
    for (const key of ["minimum", "maximum"]) {
      if (Object.hasOwn(rule, key)
        && (typeof rule[key] !== "number" || !Number.isFinite(rule[key]))) {
        invalidValue(path, key, "a finite number");
      }
    }
    if (Object.hasOwn(rule, "uniqueItems") && typeof rule.uniqueItems !== "boolean") {
      invalidValue(path, "uniqueItems", "a boolean");
    }
    if (typeof rule.pattern === "string") {
      try {
        new RegExp(rule.pattern, "u");
      } catch {
        issues.push(issue("SCHEMA_PATTERN_INVALID", `${path}.pattern`,
          `schema pattern is invalid: "${rule.pattern}"`));
      }
    }
    if (Number.isInteger(rule.minLength) && Number.isInteger(rule.maxLength)
      && rule.minLength > rule.maxLength) {
      issues.push(issue("SCHEMA_BOUND_INVALID", path,
        "minLength cannot be greater than maxLength"));
    }
    if (typeof rule.minimum === "number" && typeof rule.maximum === "number"
      && rule.minimum > rule.maximum) {
      issues.push(issue("SCHEMA_BOUND_INVALID", path,
        "minimum cannot be greater than maximum"));
    }
    if (isPlainObject(rule.properties)) {
      for (const [key, child] of Object.entries(rule.properties)) {
        walk(child, `${path}.properties.${key}`);
      }
    }
    if (isPlainObject(rule.$defs)) {
      for (const [key, child] of Object.entries(rule.$defs)) {
        walk(child, `${path}.$defs.${key}`);
      }
    }
    if (isPlainObject(rule.items)) walk(rule.items, `${path}.items`);
    if (isPlainObject(rule.additionalProperties)) {
      walk(rule.additionalProperties, `${path}.additionalProperties`);
    }
    activeRules.delete(rule);
  }
  walk(schema, "$");

  const activeReferences = new Set();
  const checkedReferences = new Set();
  const activeReferenceRules = new WeakSet();
  const checkedReferenceRules = new WeakSet();
  function checkReferences(rule, path) {
    if (!isPlainObject(rule)) return;
    if (typeof rule.$ref === "string" && rule.$ref.startsWith("#/")) {
      const resolved = resolveLocalReference(schema, rule.$ref);
      if (!isPlainObject(resolved)) {
        issues.push(issue("SCHEMA_REF_UNRESOLVED", `${path}.$ref`,
          `cannot resolve local schema reference "${rule.$ref}"`));
      } else if (activeReferences.has(rule.$ref)) {
        issues.push(issue("SCHEMA_REF_CYCLE", `${path}.$ref`,
          `recursive schema reference is not supported: "${rule.$ref}"`));
        return;
      } else if (!checkedReferences.has(rule.$ref)) {
        activeReferences.add(rule.$ref);
        checkReferences(resolved, rule.$ref);
        activeReferences.delete(rule.$ref);
        checkedReferences.add(rule.$ref);
      }
    }
    if (activeReferenceRules.has(rule) || checkedReferenceRules.has(rule)) return;
    activeReferenceRules.add(rule);
    if (isPlainObject(rule.properties)) {
      for (const [key, child] of Object.entries(rule.properties)) {
        checkReferences(child, `${path}.properties.${key}`);
      }
    }
    if (isPlainObject(rule.$defs)) {
      for (const [key, child] of Object.entries(rule.$defs)) {
        checkReferences(child, `${path}.$defs.${key}`);
      }
    }
    if (isPlainObject(rule.items)) checkReferences(rule.items, `${path}.items`);
    if (isPlainObject(rule.additionalProperties)) {
      checkReferences(rule.additionalProperties, `${path}.additionalProperties`);
    }
    activeReferenceRules.delete(rule);
    checkedReferenceRules.add(rule);
  }
  checkReferences(schema, "$");
  return issues;
}

function jsonPath(parent, key) {
  return /^[A-Za-z_$][A-Za-z0-9_$]*$/.test(key)
    ? `${parent}.${key}`
    : `${parent}[${JSON.stringify(key)}]`;
}

export function findDuplicateJsonKeys(text) {
  const duplicates = [];
  let cursor = 0;

  function skipWhitespace() {
    while (/\s/.test(text[cursor] ?? "")) cursor += 1;
  }

  function parseString() {
    const start = cursor;
    cursor += 1;
    while (cursor < text.length) {
      if (text[cursor] === "\\") {
        cursor += 2;
      } else if (text[cursor] === '"') {
        cursor += 1;
        return JSON.parse(text.slice(start, cursor));
      } else {
        cursor += 1;
      }
    }
    throw new Error("unterminated JSON string");
  }

  function parseValue(path) {
    skipWhitespace();
    if (text[cursor] === "{") {
      cursor += 1;
      skipWhitespace();
      const keys = new Set();
      if (text[cursor] === "}") {
        cursor += 1;
        return;
      }
      while (cursor < text.length) {
        skipWhitespace();
        if (text[cursor] !== '"') throw new Error("object key is not a JSON string");
        const key = parseString();
        const childPath = jsonPath(path, key);
        if (keys.has(key)) {
          duplicates.push(issue("JSON_DUPLICATE_KEY", childPath,
            `duplicate JSON object key "${key}" is not allowed`));
        }
        keys.add(key);
        skipWhitespace();
        if (text[cursor] !== ":") throw new Error("object key is missing ':'");
        cursor += 1;
        parseValue(childPath);
        skipWhitespace();
        if (text[cursor] === "}") {
          cursor += 1;
          return;
        }
        if (text[cursor] !== ",") throw new Error("object entry is missing ','");
        cursor += 1;
      }
      throw new Error("unterminated JSON object");
    }
    if (text[cursor] === "[") {
      cursor += 1;
      skipWhitespace();
      let index = 0;
      if (text[cursor] === "]") {
        cursor += 1;
        return;
      }
      while (cursor < text.length) {
        parseValue(`${path}[${index}]`);
        index += 1;
        skipWhitespace();
        if (text[cursor] === "]") {
          cursor += 1;
          return;
        }
        if (text[cursor] !== ",") throw new Error("array entry is missing ','");
        cursor += 1;
      }
      throw new Error("unterminated JSON array");
    }
    if (text[cursor] === '"') {
      parseString();
      return;
    }
    const match = text.slice(cursor).match(/^(?:true|false|null|-?(?:0|[1-9]\d*)(?:\.\d+)?(?:[eE][+-]?\d+)?)/);
    if (!match) throw new Error("invalid JSON value");
    cursor += match[0].length;
  }

  try {
    parseValue("$");
  } catch {
    return [];
  }
  return duplicates;
}
function pathIsWithin(root, candidate) {
  const fromRoot = relative(root, candidate);
  return fromRoot === ""
    || (!isAbsolute(fromRoot) && fromRoot !== ".." && !fromRoot.startsWith(`..${sep}`));
}

function issue(code, path, message, line = 1) {
  return { code, path, line, message };
}

function typeMatches(value, expected) {
  if (expected === "object") return isPlainObject(value);
  if (expected === "array") return Array.isArray(value);
  if (expected === "integer") return Number.isInteger(value);
  if (expected === "null") return value === null;
  return typeof value === expected;
}

function resolveLocalReference(rootSchema, reference) {
  if (!reference.startsWith("#/")) return null;
  let current = rootSchema;
  for (const rawPart of reference.slice(2).split("/")) {
    const part = rawPart.replace(/~1/g, "/").replace(/~0/g, "~");
    if (!isPlainObject(current) || !Object.hasOwn(current, part)) return null;
    current = current[part];
  }
  return current;
}

function validDate(value) {
  if (!/^\d{4}-\d{2}-\d{2}$/.test(value)) return false;
  const parsed = new Date(`${value}T00:00:00.000Z`);
  return !Number.isNaN(parsed.valueOf()) && parsed.toISOString().slice(0, 10) === value;
}

function validUri(value) {
  try {
    const parsed = new URL(value);
    return Boolean(parsed.protocol && parsed.hostname);
  } catch {
    return false;
  }
}

export function validateJsonSchemaValue(value, schema, options = {}) {
  const rootSchema = options.rootSchema ?? schema;
  const startPath = options.path ?? "$";
  const issues = [];
  issues.push(...validateSchemaDocument(rootSchema));
  if (issues.length > 0) return issues;

  function visit(candidate, rule, candidatePath, referenceStack = new Set()) {
    if (!isPlainObject(rule)) {
      issues.push(issue("SCHEMA_RULE_INVALID", candidatePath, "schema rule must be an object"));
      return;
    }

    if (rule.$ref) {
      const resolved = resolveLocalReference(rootSchema, rule.$ref);
      if (!resolved) {
        issues.push(issue("SCHEMA_REF_UNRESOLVED", candidatePath,
          `cannot resolve local schema reference "${rule.$ref}"`));
        return;
      }
      if (referenceStack.has(rule.$ref)) {
        issues.push(issue("SCHEMA_REF_CYCLE", candidatePath,
          `recursive schema reference is not supported: "${rule.$ref}"`));
        return;
      }
      const nextStack = new Set(referenceStack);
      nextStack.add(rule.$ref);
      visit(candidate, resolved, candidatePath, nextStack);
      return;
    }

    if (Object.hasOwn(rule, "const") && !valuesEqual(candidate, rule.const)) {
      issues.push(issue("SCHEMA_CONST", candidatePath,
        `must equal ${JSON.stringify(rule.const)}`));
    }
    if (Array.isArray(rule.enum) && !rule.enum.some((allowed) => valuesEqual(candidate, allowed))) {
      issues.push(issue("SCHEMA_ENUM", candidatePath,
        `must be one of ${rule.enum.map((allowed) => JSON.stringify(allowed)).join(", ")}`));
    }

    if (rule.type && !typeMatches(candidate, rule.type)) {
      issues.push(issue("SCHEMA_TYPE", candidatePath, `must be ${rule.type}`));
      return;
    }

    if (typeof candidate === "string") {
      if (Number.isInteger(rule.minLength) && candidate.length < rule.minLength) {
        issues.push(issue("SCHEMA_MIN_LENGTH", candidatePath,
          `must contain at least ${rule.minLength} character(s)`));
      }
      if (Number.isInteger(rule.maxLength) && candidate.length > rule.maxLength) {
        issues.push(issue("SCHEMA_MAX_LENGTH", candidatePath,
          `must contain at most ${rule.maxLength} character(s)`));
      }
      if (rule.pattern) {
        let pattern;
        try {
          pattern = new RegExp(rule.pattern, "u");
        } catch {
          issues.push(issue("SCHEMA_PATTERN_INVALID", candidatePath,
            `schema pattern is invalid: "${rule.pattern}"`));
        }
        if (pattern && !pattern.test(candidate)) {
          issues.push(issue("SCHEMA_PATTERN", candidatePath,
            `does not match required pattern ${rule.pattern}`));
        }
      }
      if (rule.format === "date" && !validDate(candidate)) {
        issues.push(issue("SCHEMA_DATE", candidatePath, "must be a real YYYY-MM-DD date"));
      }
      if (rule.format === "uri" && !validUri(candidate)) {
        issues.push(issue("SCHEMA_URI", candidatePath, "must be an absolute URI"));
      }
    }

    if (typeof candidate === "number") {
      if (typeof rule.minimum === "number" && candidate < rule.minimum) {
        issues.push(issue("SCHEMA_MINIMUM", candidatePath,
          `must be greater than or equal to ${rule.minimum}`));
      }
      if (typeof rule.maximum === "number" && candidate > rule.maximum) {
        issues.push(issue("SCHEMA_MAXIMUM", candidatePath,
          `must be less than or equal to ${rule.maximum}`));
      }
    }

    if (Array.isArray(candidate)) {
      if (Number.isInteger(rule.minItems) && candidate.length < rule.minItems) {
        issues.push(issue("SCHEMA_MIN_ITEMS", candidatePath,
          `must contain at least ${rule.minItems} item(s)`));
      }
      if (rule.uniqueItems) {
        const seen = new Set();
        for (let index = 0; index < candidate.length; index += 1) {
          const key = JSON.stringify(candidate[index]);
          if (seen.has(key)) {
            issues.push(issue("SCHEMA_UNIQUE_ITEMS", `${candidatePath}[${index}]`,
              "must not duplicate an earlier item"));
          }
          seen.add(key);
        }
      }
      if (rule.items) {
        candidate.forEach((item, index) => visit(item, rule.items, `${candidatePath}[${index}]`));
      }
    }

    if (isPlainObject(candidate)) {
      const properties = isPlainObject(rule.properties) ? rule.properties : {};
      if (Array.isArray(rule.required)) {
        for (const required of rule.required) {
          if (!Object.hasOwn(candidate, required)) {
            issues.push(issue("SCHEMA_REQUIRED", `${candidatePath}.${required}`,
              "required field is missing"));
          }
        }
      }
      for (const [key, child] of Object.entries(candidate)) {
        if (Object.hasOwn(properties, key)) {
          visit(child, properties[key], `${candidatePath}.${key}`);
        } else if (rule.additionalProperties === false) {
          issues.push(issue("SCHEMA_UNKNOWN_FIELD", `${candidatePath}.${key}`,
            "unknown field is not allowed"));
        } else if (isPlainObject(rule.additionalProperties)) {
          visit(child, rule.additionalProperties, `${candidatePath}.${key}`);
        }
      }
    }
  }

  visit(value, schema, startPath);
  return issues;
}

export function parseJsonFrontMatter(text) {
  const normalized = text.replace(/^\uFEFF/, "");
  const lines = normalized.split(/\r?\n/);
  if (lines[0]?.trim() !== "---") {
    return {
      issues: [issue("FRONT_MATTER_MISSING", "$",
        "lesson must start with a JSON front-matter block delimited by ---")],
    };
  }
  const closing = lines.findIndex((line, index) => index > 0 && line.trim() === "---");
  if (closing === -1) {
    return {
      issues: [issue("FRONT_MATTER_UNCLOSED", "$",
        "front-matter block is missing its closing ---")],
    };
  }
  const raw = lines.slice(1, closing).join("\n");
  const duplicateKeys = findDuplicateJsonKeys(raw);
  if (duplicateKeys.length > 0) {
    return {
      issues: duplicateKeys.map((entry) => ({ ...entry, line: 2 })),
    };
  }
  try {
    return {
      metadata: JSON.parse(raw),
      body: lines.slice(closing + 1).join("\n"),
      bodyStartLine: closing + 2,
      issues: [],
    };
  } catch {
    return {
      issues: [issue("FRONT_MATTER_JSON", "$",
        "front matter must be valid strict JSON; comments and implicit YAML values are not accepted",
      2)],
    };
  }
}

function visibleOutsideHtmlComments(line, state) {
  let visible = "";
  let cursor = 0;
  while (cursor < line.length) {
    if (state.open) {
      const closing = line.indexOf("-->", cursor);
      if (closing === -1) return visible;
      cursor = closing + 3;
      state.open = false;
      continue;
    }
    const opening = line.indexOf("<!--", cursor);
    if (opening === -1) {
      visible += line.slice(cursor);
      break;
    }
    visible += line.slice(cursor, opening);
    const closing = line.indexOf("-->", opening + 4);
    if (closing === -1) {
      state.open = true;
      break;
    }
    cursor = closing + 3;
  }
  return visible;
}

function parseFenceOpening(line) {
  const marker = line.match(/^\s{0,3}(`{3,}|~{3,})(.*)$/);
  if (!marker) return null;
  const character = marker[1][0];
  if (character === "`" && marker[2].includes("`")) return null;
  return { character, length: marker[1].length };
}

function extractHeadings(body, level) {
  const headings = [];
  const lines = body.split(/\r?\n/);
  let fence = null;
  const commentState = { open: false };
  for (let index = 0; index < lines.length; index += 1) {
    const originalLine = lines[index];
    if (fence) {
      const closing = originalLine.match(/^\s{0,3}(`{3,}|~{3,})\s*$/);
      if (closing && closing[1][0] === fence.character
        && closing[1].length >= fence.length) {
        fence = null;
      }
      continue;
    }
    const line = visibleOutsideHtmlComments(originalLine, commentState);
    const marker = parseFenceOpening(line);
    if (marker) {
      fence = marker;
      continue;
    }
    const heading = line.match(/^\s{0,3}(#{1,2})(?:[ \t]+|$)(.*)$/);
    if (heading && heading[1].length === level) {
      headings.push({
        text: heading[2].replace(/[ \t]+#+[ \t]*$/, "").trim(),
        line: index + 1,
      });
    }
  }
  return headings;
}

function extractLevelTwoHeadings(body) {
  return extractHeadings(body, 2);
}

const rawHtmlBlockTagPattern = /^\s{0,3}<\/?(address|article|aside|base|basefont|blockquote|body|caption|center|col|colgroup|dd|details|dialog|dir|div|dl|dt|fieldset|figcaption|figure|footer|form|frame|frameset|h[1-6]|head|header|hr|html|iframe|legend|li|link|main|menu|menuitem|nav|noframes|ol|optgroup|option|p|param|pre|script|search|section|style|summary|table|tbody|td|textarea|tfoot|th|thead|title|tr|track|ul)(?:\s|\/?>|$)/i;
const rawHtmlDeclarationPattern = /^\s{0,3}(?:<\?|<![A-Z]|<!\[CDATA\[)/;
const rawHtmlTagStartPattern = /^\s{0,3}<\/?[A-Za-z][A-Za-z0-9-]*(?:\s|\/?>|$)/;

function unsupportedRawHtmlLine(body) {
  const lines = body.split(/\r?\n/);
  let fence = null;
  for (let index = 0; index < lines.length; index += 1) {
    const line = lines[index];
    if (fence) {
      const closing = line.match(/^\s{0,3}(`{3,}|~{3,})\s*$/);
      if (closing && closing[1][0] === fence.character
        && closing[1].length >= fence.length) fence = null;
      continue;
    }
    const marker = parseFenceOpening(line);
    if (marker) {
      fence = marker;
      continue;
    }
    if (line.includes("<!--") || rawHtmlDeclarationPattern.test(line)
      || rawHtmlBlockTagPattern.test(line) || rawHtmlTagStartPattern.test(line)) {
      return index + 1;
    }
  }
  return null;
}

function markdownDestinationIssues(body) {
  const issues = [];
  const lines = body.split(/\r?\n/);
  let fence = null;

  for (let index = 0; index < lines.length; index += 1) {
    const line = lines[index];
    if (fence) {
      const closing = line.match(/^\s{0,3}(`{3,}|~{3,})\s*$/);
      if (closing && closing[1][0] === fence.character
        && closing[1].length >= fence.length) fence = null;
      continue;
    }
    const marker = parseFenceOpening(line);
    if (marker) {
      fence = marker;
      continue;
    }

    const inlineDestination = /(!?)\[[^\]\n]*\]\(\s*(<[^>\n]+>|[^\s)]+)(?:\s+(?:"[^"]*"|'[^']*'))?\s*\)/g;
    for (const match of line.matchAll(inlineDestination)) {
      const destination = match[2].startsWith("<") && match[2].endsWith(">")
        ? match[2].slice(1, -1) : match[2];
      if (match[1] === "!") {
        issues.push(issue("LESSON_MARKDOWN_IMAGE_UNSUPPORTED", "body",
          "schema-v1 lessons cannot embed Markdown images or trigger remote image requests",
          index + 1));
        continue;
      }
      if (/^#[a-z0-9]+(?:-[a-z0-9]+)*$/.test(destination)
        || /^\/book\/[a-z0-9]+(?:\/[a-z0-9-]+)+(?:#[a-z0-9]+(?:-[a-z0-9]+)*)?$/.test(destination)) {
        continue;
      }
      if (destination.startsWith("https://")) {
        try {
          const parsed = new URL(destination);
          if (parsed.href === destination && !parsed.username && !parsed.password) continue;
        } catch {
          // The closed-policy issue below is the stable learner-facing diagnostic.
        }
      }
      issues.push(issue("LESSON_MARKDOWN_DESTINATION_UNSAFE", "body",
        `Markdown links must use canonical HTTPS, a /book route, or a local heading anchor; received "${destination}"`,
        index + 1));
    }
  }
  return issues;
}

function obviousMutationInReadOnlyCommand(command) {
  if (typeof command !== "string") return false;
  const trimmed = command.trim();
  if (/^command[ \t]+-v(?:[ \t]+--)?(?:[ \t]+[A-Za-z0-9][A-Za-z0-9._+-]*)+$/.test(trimmed)) {
    return false;
  }
  const mutator = /\b(?:rm|mv|cp|touch|mkdir|rmdir|chmod|chown|chgrp|ln|truncate|mkfs|fdisk|parted|dd|mount|umount|kill|pkill|killall|reboot|shutdown)\b|\b(?:systemctl|service)\s+(?:start|stop|restart|reload|enable|disable|mask|unmask)\b|\b(?:apt|apt-get|dnf|yum|apk)\s+(?:install|remove|purge|upgrade|dist-upgrade)\b|\b(?:docker|podman)\s+(?:run|rm|rmi|stop|kill|exec|build|pull)\b|\bkubectl\s+(?:apply|create|delete|edit|patch|replace|scale|rollout)\b|\bterraform\s+(?:apply|destroy|import)\b|\b(?:sed|perl)\s+-i\b|\bfind\b[^\n]*\s-delete\b/i;
  return mutator.test(command);
}

function sectionHasMeaningfulContent(bodyLines, headingLine, nextHeadingLine) {
  const raw = bodyLines.slice(headingLine, nextHeadingLine - 1).join("\n");
  const visible = raw
    .replace(/<!--[\s\S]*?(?:-->|$)/g, "")
    .replace(/^\s{0,3}(?:`{3,}|~{3,}).*$/gm, "")
    .replace(/^\s{0,3}#{1,6}(?:[ \t]+|$).*$/gm, "")
    .replace(/[\x60*_~>|#-]/g, " ");
  return /[\p{L}\p{N}]/u.test(visible);
}

function validateReviewWindow(record, path = "$") {
  if (!isPlainObject(record) || !validDate(record.lastReviewed)
    || !validDate(record.reviewAfter)) return [];
  if (record.reviewAfter <= record.lastReviewed) {
    return [issue("REVIEW_WINDOW_INVALID", `${path}.reviewAfter`,
      "reviewAfter must be later than lastReviewed")];
  }
  return [];
}

function validateChildIds(lesson) {
  if (!isPlainObject(lesson) || typeof lesson.id !== "string") return [];
  const issues = [];
  const seen = new Map();
  for (const [field, suffix] of Object.entries(artifactSuffixByField)) {
    const records = Array.isArray(lesson[field]) ? lesson[field] : [];
    for (let index = 0; index < records.length; index += 1) {
      const childId = typeof records[index] === "string" ? records[index] : records[index]?.id;
      const expected = new RegExp(`^${lesson.id}-${suffix}-[0-9]{3}$`);
      if (typeof childId === "string" && !expected.test(childId)) {
        issues.push(issue("CHILD_ID_MISMATCH", `$.${field}[${index}]`,
          `ID must belong to ${lesson.id} and use the ${suffix} artifact type`));
      }
      if (typeof childId === "string") {
        const firstField = seen.get(childId);
        if (firstField) {
          issues.push(issue("DUPLICATE_CHILD_ID", `$.${field}[${index}]`,
            `ID is already used by ${firstField}`));
        } else seen.set(childId, `$.${field}[${index}]`);
      }
    }
  }
  return issues;
}

export function validateLessonDocument(text, schema) {
  const parsed = parseJsonFrontMatter(text);
  if (parsed.issues.length > 0) return { ...parsed, issues: parsed.issues };
  const issues = [
    ...validateJsonSchemaValue(parsed.metadata, schema),
    ...validateReviewWindow(parsed.metadata),
    ...validateChildIds(parsed.metadata),
  ];
  if (isPlainObject(parsed.metadata)
    && Array.isArray(parsed.metadata.prerequisiteLessonIds)
    && parsed.metadata.prerequisiteLessonIds.includes(parsed.metadata.id)) {
    issues.push(issue("PREREQUISITE_SELF", "$.prerequisiteLessonIds",
      "a lesson cannot depend on itself"));
  }
  if (isPlainObject(parsed.metadata)
    && Array.isArray(parsed.metadata.curriculumIds)
    && Array.isArray(parsed.metadata.prerequisiteCurriculumIds)) {
    for (const prerequisite of parsed.metadata.prerequisiteCurriculumIds) {
      if (parsed.metadata.curriculumIds.includes(prerequisite)) {
        issues.push(issue("PREREQUISITE_CURRICULUM_SELF", "$.prerequisiteCurriculumIds",
          `lesson cannot require its own curriculum ID "${prerequisite}"`));
      }
    }
  }
  if (isPlainObject(parsed.metadata) && isPlainObject(parsed.metadata.level)) {
    const from = levelOrder[parsed.metadata.level.from];
    const to = levelOrder[parsed.metadata.level.to];
    if (Number.isInteger(from) && Number.isInteger(to) && from > to) {
      issues.push(issue("LESSON_LEVEL_RANGE", "$.level",
        "level.from cannot be more advanced than level.to"));
    }
  }
  if (isPlainObject(parsed.metadata) && Array.isArray(parsed.metadata.aliases)
    && !parsed.metadata.aliases.some((alias) => /^V[0-9]{2}-L[0-9]{2,3}$/.test(alias))) {
    issues.push(issue("LESSON_PUBLIC_ALIAS_MISSING", "$.aliases",
      "at least one stable public lesson alias such as V01-L06 is required"));
  }

  if (isPlainObject(parsed.metadata) && Array.isArray(parsed.metadata.commands)) {
    parsed.metadata.commands.forEach((command, index) => {
      const mutating = isPlainObject(command)
        && !["read-only", "sampled-read-only"].includes(command.risk);
      const assertedReadOnly = isPlainObject(command)
        && ["read-only", "sampled-read-only"].includes(command.risk);
      if (mutating && (typeof command.cleanup !== "string" || command.cleanup.trim() === "")) {
        issues.push(issue("MUTATING_COMMAND_CLEANUP", `$.commands[${index}].cleanup`,
          "a mutating, destructive, or networked command requires explicit cleanup"));
      }
      if (assertedReadOnly && obviousMutationInReadOnlyCommand(command.command)) {
        issues.push(issue("READ_ONLY_COMMAND_MUTATION_HINT", `$.commands[${index}].command`,
          "a command containing an obvious mutator cannot be labeled read-only"));
      }
    });
  }

  const rawHtmlLine = unsupportedRawHtmlLine(parsed.body);
  if (rawHtmlLine !== null) {
    issues.push(issue("LESSON_RAW_HTML_UNSUPPORTED", "body",
      "schema-v1 lesson structure cannot use raw HTML blocks or HTML comments",
      parsed.bodyStartLine + rawHtmlLine - 1));
  }
  issues.push(...markdownDestinationIssues(parsed.body).map((entry) => ({
    ...entry, line: parsed.bodyStartLine + entry.line - 1,
  })));
  const titleHeadings = extractHeadings(parsed.body, 1);
  if (titleHeadings.length === 0) {
    issues.push(issue("LESSON_TITLE_HEADING_MISSING", "body.#",
      "lesson body requires one level-one title", parsed.bodyStartLine));
  } else {
    if (titleHeadings.length > 1) {
      issues.push(issue("LESSON_TITLE_HEADING_DUPLICATE", "body.#",
        "lesson body must contain exactly one level-one title",
        parsed.bodyStartLine + titleHeadings[1].line - 1));
    }
    if (typeof parsed.metadata?.title === "string"
      && titleHeadings[0].text !== parsed.metadata.title) {
      issues.push(issue("LESSON_TITLE_HEADING_MISMATCH", "body.#",
        "level-one body title must exactly match metadata.title",
        parsed.bodyStartLine + titleHeadings[0].line - 1));
    }
  }
  const headings = extractLevelTwoHeadings(parsed.body);
  const positions = new Map();
  const bodyLines = parsed.body.split(/\r?\n/);
  headings.forEach((heading, index) => {
    if (positions.has(heading.text)) {
      issues.push(issue("LESSON_HEADING_DUPLICATE", `body.## ${heading.text}`,
        "required lesson heading must appear once", parsed.bodyStartLine + heading.line - 1));
    } else {
      positions.set(heading.text, index);
    }
  });
  let prior = -1;
  for (const required of REQUIRED_LESSON_HEADINGS) {
    if (!positions.has(required)) {
      issues.push(issue("LESSON_HEADING_MISSING", `body.## ${required}`,
        "required level-two lesson section is missing", parsed.bodyStartLine));
      continue;
    }
    const current = positions.get(required);
    if (current < prior) {
      issues.push(issue("LESSON_HEADING_ORDER", `body.## ${required}`,
        "required lesson sections must follow the canonical order", parsed.bodyStartLine));
    }
    const heading = headings[current];
    const nextHeadingLine = headings[current + 1]?.line ?? bodyLines.length + 1;
    if (!sectionHasMeaningfulContent(bodyLines, heading.line, nextHeadingLine)) {
      issues.push(issue("LESSON_SECTION_EMPTY", `body.## ${required}`,
        "required lesson section must contain explanatory content",
        parsed.bodyStartLine + heading.line - 1));
    }
    prior = Math.max(prior, current);
  }
  return { ...parsed, issues };
}

export function validateAssessmentRecord(record, schema) {
  const issues = [
    ...validateJsonSchemaValue(record, schema),
    ...validateReviewWindow(record),
  ];
  if (isPlainObject(record) && record.type === "independent-transfer") {
    for (const field of independentTransferFields) {
      if (!Object.hasOwn(record, field)) {
        issues.push(issue("INDEPENDENT_TRANSFER_FIELD_MISSING", `$.${field}`,
          `independent-transfer assessments require ${field}`));
      }
    }
    for (const field of assessmentAnswerFields) {
      if (Object.hasOwn(record, field)) {
        issues.push(issue("INDEPENDENT_TRANSFER_ANSWER_LEAK", `$.${field}`,
          "independent-transfer records must not contain model answers or answer-derived evidence"));
      }
    }
  } else if (isPlainObject(record)) {
    for (const field of assessmentAnswerFields) {
      if (!Object.hasOwn(record, field)) {
        issues.push(issue("ASSESSMENT_ANSWER_FIELD_MISSING", `$.${field}`,
          `answered assessments require ${field}`));
      }
    }
    for (const field of independentTransferFields) {
      if (Object.hasOwn(record, field)) {
        issues.push(issue("ASSESSMENT_TRANSFER_FIELD_UNEXPECTED", `$.${field}`,
          "independent-transfer fields are allowed only when type is independent-transfer"));
      }
    }
  }
  if (isPlainObject(record) && Array.isArray(record.rubric)
    && Number.isInteger(record.maximumScore)) {
    const total = record.rubric.reduce((sum, row) =>
      sum + (isPlainObject(row) && Number.isInteger(row.points) ? row.points : 0), 0);
    if (total !== record.maximumScore) {
      issues.push(issue("RUBRIC_SCORE_MISMATCH", "$.maximumScore",
        `maximumScore is ${record.maximumScore}, but rubric points total ${total}`));
    }
  }
  return issues;
}

export function validateReferenceRecord(record, schema) {
  const issues = [
    ...validateJsonSchemaValue(record, schema),
    ...validateReviewWindow(record),
  ];
  if (isPlainObject(record) && typeof record.url === "string") {
    const hasRawWhitespace = /[\u0000-\u0020\u007f]/u.test(record.url);
    if (hasRawWhitespace) {
      issues.push(issue("REFERENCE_URL_RAW_WHITESPACE", "$.url",
        "reference URLs must not contain raw spaces or control characters"));
    }
    try {
      const parsed = new URL(record.url);
      if (!hasRawWhitespace && parsed.href !== record.url) {
        issues.push(issue("REFERENCE_URL_NORMALIZATION_DRIFT", "$.url",
          `URL must use its exact canonical serialization: "${parsed.href}"`));
      }
      if (parsed.username || parsed.password) {
        issues.push(issue("REFERENCE_URL_CREDENTIALS", "$.url",
          "reference URLs must not contain embedded credentials"));
      }
      if (parsed.search) {
        issues.push(issue("REFERENCE_URL_QUERY_FORBIDDEN", "$.url",
          "durable reference URLs must not contain query parameters"));
      }
      if (parsed.hash) {
        issues.push(issue("REFERENCE_URL_FRAGMENT_FORBIDDEN", "$.url",
          "durable reference URLs must not contain fragments"));
      }
    } catch {
      // URI syntax is reported by the schema validator.
    }
  }
  return issues;
}

function exactCaseMismatch(root, candidate) {
  const fromRoot = relative(root, candidate);
  let cursor = root;
  for (const component of fromRoot.split(sep).filter(Boolean)) {
    let entries;
    try {
      entries = readdirSync(cursor);
    } catch (error) {
      if (["ENOENT", "ENOTDIR"].includes(error?.code)) return null;
      throw error;
    }
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

function lexicalStat(path) {
  try {
    return lstatSync(path);
  } catch (error) {
    if (["ENOENT", "ENOTDIR"].includes(error?.code)) return null;
    throw error;
  }
}

function collectFiles(directory, predicate, symlinks = []) {
  const directoryStat = lexicalStat(directory);
  if (!directoryStat) return [];
  if (directoryStat.isSymbolicLink()) {
    symlinks.push(directory);
    return [];
  }
  const files = [];
  for (const entry of readdirSync(directory, { withFileTypes: true })
    .sort((left, right) => left.name.localeCompare(right.name))) {
    const entryPath = join(directory, entry.name);
    if (entry.isSymbolicLink()) symlinks.push(entryPath);
    else if (entry.isDirectory()) files.push(...collectFiles(entryPath, predicate, symlinks));
    else if (entry.isFile() && predicate(entryPath)) files.push(entryPath);
  }
  return files;
}

function loadJson(filePath, repositoryRoot, issues) {
  try {
    const raw = readFileSync(filePath, "utf8");
    const duplicateKeys = findDuplicateJsonKeys(raw);
    if (duplicateKeys.length > 0) {
      issues.push(...duplicateKeys.map((entry) => ({
        ...entry, file: displayPath(repositoryRoot, filePath),
      })));
      return null;
    }
    return JSON.parse(raw);
  } catch {
    issues.push({
      ...issue("JSON_PARSE", "$",
        "file must contain valid strict JSON"),
      file: displayPath(repositoryRoot, filePath),
    });
    return null;
  }
}

export function collectCurriculumIdsFromMarkdown(text) {
  const ids = new Set();
  const commentState = { open: false };
  let fence = null;
  let rawHtmlEnd = null;
  let inCanonicalTable = false;
  for (const originalLine of text.split(/\r?\n/)) {
    if (fence) {
      const closing = originalLine.match(/^\s{0,3}(`{3,}|~{3,})\s*$/);
      if (closing && closing[1][0] === fence.character
        && closing[1].length >= fence.length) fence = null;
      continue;
    }
    const line = visibleOutsideHtmlComments(originalLine, commentState);
    const marker = parseFenceOpening(line);
    if (marker) {
      fence = marker;
      inCanonicalTable = false;
      continue;
    }
    if (rawHtmlEnd) {
      if (rawHtmlEnd.kind === "blank" && originalLine.trim() === "") rawHtmlEnd = null;
      else if (rawHtmlEnd.kind === "pattern" && rawHtmlEnd.pattern.test(originalLine)) {
        rawHtmlEnd = null;
      }
      continue;
    }
    const rawOpening = originalLine.match(rawHtmlBlockTagPattern);
    if (rawOpening) {
      const tag = rawOpening[1].toLowerCase();
      if (!new RegExp(`</${tag}\\s*>`, "i").test(originalLine)) {
        rawHtmlEnd = { kind: "pattern", pattern: new RegExp(`</${tag}\\s*>`, "i") };
      }
      inCanonicalTable = false;
      continue;
    }
    if (/^\s{0,3}<\?/.test(originalLine)) {
      if (!originalLine.includes("?>")) rawHtmlEnd = { kind: "pattern", pattern: /\?>/ };
      inCanonicalTable = false;
      continue;
    }
    if (/^\s{0,3}<!\[CDATA\[/.test(originalLine)) {
      if (!originalLine.includes("]]>")) rawHtmlEnd = { kind: "pattern", pattern: /\]\]>/ };
      inCanonicalTable = false;
      continue;
    }
    if (rawHtmlDeclarationPattern.test(originalLine)
      || rawHtmlTagStartPattern.test(originalLine)) {
      rawHtmlEnd = { kind: "blank" };
      inCanonicalTable = false;
      continue;
    }
    const startsAsTableRow = /^\s{0,3}\|/.test(originalLine);
    if (startsAsTableRow && /^\s{0,3}\|\s*ID\s*\|\s*Req\.\s*\|/.test(line)) {
      inCanonicalTable = true;
      continue;
    }
    if (!inCanonicalTable) continue;
    if (!startsAsTableRow) {
      inCanonicalTable = false;
      continue;
    }
    const cells = line.trim().slice(1, -1).split("|").map((cell) => cell.trim());
    if (cells.every((cell) => /^:?-{3,}:?$/.test(cell))) continue;
    if (cells.length !== 11) {
      inCanonicalTable = false;
      continue;
    }
    if (/^[A-Z][A-Z0-9]{1,15}-[0-9]{3}$/.test(cells[0])
      && /^\d+(?:,\d+)*$/.test(cells[1])) ids.add(cells[0]);
  }
  return ids;
}

function sameStringSet(left, right) {
  return Array.isArray(left) && Array.isArray(right)
    && left.length === right.length
    && left.every((value) => right.includes(value));
}

function legacyIdentityDigest(lessons) {
  const identities = lessons.map((lesson) => ({
    id: lesson?.id,
    aliases: Array.isArray(lesson?.aliases) ? [...lesson.aliases].sort() : lesson?.aliases,
    curriculumIds: Array.isArray(lesson?.curriculumIds)
      ? [...lesson.curriculumIds].sort() : lesson?.curriculumIds,
    slug: lesson?.slug,
    route: lesson?.route,
  })).sort((left, right) => String(left.id).localeCompare(String(right.id)));
  return createHash("sha256").update(JSON.stringify(identities)).digest("hex");
}

function labPathUsesAllowedRoot(value) {
  if (typeof value !== "string" || value.includes("\\") || value.includes(":")) return false;
  const parts = value.split("/");
  if (parts.some((part) => part === "" || part === "." || part === ".."
    || part.toLocaleLowerCase("en-US") === ".git")) return false;
  if (parts[0] === "labs") return parts.length >= 2;
  if (parts[0] === "book" && parts[1] === "labs") return parts.length >= 3;
  return /^phase-[0-9]{2}-[a-z0-9]+(?:-[a-z0-9]+)*$/.test(parts[0])
    && parts.length >= 2;
}

function labAllowedRoot(repositoryRoot, value) {
  const parts = value.split("/");
  if (parts[0] === "labs") return resolve(repositoryRoot, "labs");
  if (parts[0] === "book" && parts[1] === "labs") {
    return resolve(repositoryRoot, "book", "labs");
  }
  return resolve(repositoryRoot, parts[0]);
}

function exactObjectKeys(record, expected, path, addIssue) {
  if (!isPlainObject(record)) {
    addIssue("LEGACY_MAP_OBJECT", path, "value must be an object");
    return false;
  }
  const expectedSet = new Set(expected);
  for (const key of expected) {
    if (!Object.hasOwn(record, key)) {
      addIssue("LEGACY_MAP_FIELD_MISSING", `${path}.${key}`,
        "required legacy-map field is missing");
    }
  }
  for (const key of Object.keys(record)) {
    if (!expectedSet.has(key)) {
      addIssue("LEGACY_MAP_UNKNOWN_FIELD", `${path}.${key}`,
        "unknown legacy-map field is not allowed");
    }
  }
  return true;
}

function validateLegacyContentMap(repositoryRoot, curriculumIds, issues) {
  const mapPath = join(repositoryRoot, "book", "schema", legacyMapFileName);
  const file = displayPath(repositoryRoot, mapPath);
  const empty = {
    entries: [],
    byId: new Map(),
    routes: new Map(),
    slugs: new Map(),
    aliases: new Map(),
    maxLessonNumber: 0,
    file,
  };
  const mapStat = lexicalStat(mapPath);
  if (mapStat?.isSymbolicLink()) {
    issues.push({
      ...issue("CANONICAL_POLICY_FILE_SYMLINK", "$",
        "legacy-content-map.json must be a real regular file, not a symlink"),
      file,
    });
    return empty;
  }
  if (mapStat && !mapStat.isFile()) {
    issues.push({
      ...issue("LEGACY_MAP_NOT_FILE", "$", "legacy-content-map.json must be a regular file"),
      file,
    });
    return empty;
  }
  if (mapStat && !pathIsWithin(realpathSync(repositoryRoot), realpathSync(mapPath))) {
    issues.push({
      ...issue("CANONICAL_POLICY_FILE_ESCAPE", "$",
        "legacy-content-map.json resolves outside the repository"),
      file,
    });
    return empty;
  }
  const mapCaseMismatch = exactCaseMismatch(repositoryRoot, mapPath);
  if (mapCaseMismatch) {
    issues.push({
      ...issue("CANONICAL_FILE_CASE_MISMATCH", "$",
        `canonical file requested "${mapCaseMismatch.requested}", but disk entry is "${mapCaseMismatch.actual}"`),
      file,
    });
  }
  if (!mapStat) {
    issues.push({
      ...issue("LEGACY_MAP_MISSING", "$", `${legacyMapFileName} is required`),
      file,
    });
    return empty;
  }
  const record = loadJson(mapPath, repositoryRoot, issues);
  if (!record) return empty;
  const addIssue = (code, path, message) => issues.push({
    ...issue(code, path, message),
    file,
  });
  if (!exactObjectKeys(record, ["schemaVersion", "kind", "lessons"], "$", addIssue)) {
    return empty;
  }
  if (record.schemaVersion !== 1) {
    addIssue("LEGACY_MAP_VERSION", "$.schemaVersion", "schemaVersion must equal 1");
  }
  if (record.kind !== "legacy-content-map") {
    addIssue("LEGACY_MAP_KIND", "$.kind", "kind must equal legacy-content-map");
  }
  if (!Array.isArray(record.lessons)) {
    addIssue("LEGACY_MAP_LESSONS", "$.lessons", "lessons must be an array");
    return empty;
  }
  if (legacyIdentityDigest(record.lessons) !== legacyIdentityBaselineSha256) {
    addIssue("LEGACY_IDENTITY_BASELINE_DRIFT", "$.lessons",
      "published LES-0001..LES-0005 IDs, aliases, curriculum mappings, slugs, and routes are immutable");
  }

  const entries = [];
  const byId = new Map();
  const routes = new Map();
  const slugs = new Map();
  const aliases = new Map();
  let maxLessonNumber = 0;
  function reserve(map, value, entry, code, label) {
    if (typeof value !== "string") return;
    const first = map.get(value);
    if (first) {
      addIssue(code, entry.path,
        `${label} "${value}" is already reserved by ${first.record.id}`);
    } else map.set(value, entry);
  }

  record.lessons.forEach((lesson, index) => {
    const path = `$.lessons[${index}]`;
    if (!exactObjectKeys(lesson,
      ["id", "aliases", "curriculumIds", "slug", "route", "sources"], path, addIssue)) {
      return;
    }
    if (typeof lesson.id !== "string" || !lessonIdPattern.test(lesson.id)) {
      addIssue("LEGACY_LESSON_ID", `${path}.id`, "id must match LES-####");
    }
    if (typeof lesson.slug !== "string" || !slugPattern.test(lesson.slug)) {
      addIssue("LEGACY_LESSON_SLUG", `${path}.slug`,
        "slug must contain lowercase words separated by single hyphens");
    }
    if (typeof lesson.route !== "string" || !routePattern.test(lesson.route)) {
      addIssue("LEGACY_LESSON_ROUTE", `${path}.route`,
        "route must be an explicit lowercase /book/... path without a trailing slash");
    }
    if (!Array.isArray(lesson.aliases) || lesson.aliases.length === 0
      || lesson.aliases.some((alias) => typeof alias !== "string"
        || !(publicLessonAliasPattern.test(alias) || slugPattern.test(alias)))
      || new Set(lesson.aliases).size !== lesson.aliases.length) {
      addIssue("LEGACY_LESSON_ALIASES", `${path}.aliases`,
        "aliases must be unique public aliases or lowercase slug aliases");
    } else if (!lesson.aliases.some((alias) => publicLessonAliasPattern.test(alias))) {
      addIssue("LEGACY_LESSON_PUBLIC_ALIAS", `${path}.aliases`,
        "at least one V##-L## public alias is required");
    }
    if (!Array.isArray(lesson.curriculumIds) || lesson.curriculumIds.length === 0
      || lesson.curriculumIds.some((id) => typeof id !== "string"
        || !stableIdPattern.test(id))
      || new Set(lesson.curriculumIds).size !== lesson.curriculumIds.length) {
      addIssue("LEGACY_CURRICULUM_IDS", `${path}.curriculumIds`,
        "curriculumIds must contain unique stable curriculum IDs");
    } else {
      for (const curriculumId of lesson.curriculumIds) {
        if (!curriculumIds.has(curriculumId)) {
          addIssue("LEGACY_CURRICULUM_ID_UNKNOWN", `${path}.curriculumIds`,
            `curriculum ID "${curriculumId}" is not in CONTENT_MATRIX.md`);
        }
      }
    }
    if (!Array.isArray(lesson.sources) || lesson.sources.length === 0
      || lesson.sources.some((source) => typeof source !== "string" || source.length === 0)
      || new Set(lesson.sources).size !== lesson.sources.length) {
      addIssue("LEGACY_SOURCES", `${path}.sources`,
        "sources must contain unique non-empty repository-relative file paths");
    } else {
      lesson.sources.forEach((source, sourceIndex) => {
        const sourcePath = `${path}.sources[${sourceIndex}]`;
        if (source.includes("\\") || source.includes(":") || source.startsWith("/")
          || source.split("/").some((part) => part === "" || part === "." || part === "..")) {
          addIssue("LEGACY_SOURCE_PATH", sourcePath,
            "source must be a portable repository-relative path");
          return;
        }
        const target = resolve(repositoryRoot, source);
        if (!pathIsWithin(resolve(repositoryRoot), target)) {
          addIssue("LEGACY_SOURCE_ESCAPE", sourcePath, "source path escapes the repository");
        } else if (!existsSync(target)) {
          addIssue("LEGACY_SOURCE_MISSING", sourcePath, `source does not exist: "${source}"`);
        } else if (!statSync(target).isFile()) {
          addIssue("LEGACY_SOURCE_NOT_FILE", sourcePath, "source must resolve to a file");
        } else if (!pathIsWithin(realpathSync(repositoryRoot), realpathSync(target))) {
          addIssue("LEGACY_SOURCE_SYMLINK_ESCAPE", sourcePath,
            "source resolves outside the repository through a symlink or junction");
        } else {
          const mismatch = exactCaseMismatch(repositoryRoot, target);
          if (mismatch) {
            addIssue("LEGACY_SOURCE_CASE_MISMATCH", sourcePath,
              `path requested "${mismatch.requested}", but disk entry is "${mismatch.actual}"`);
          }
        }
      });
    }

    if (typeof lesson.id !== "string" || !lessonIdPattern.test(lesson.id)) return;
    const entry = { record: lesson, path, file };
    entries.push(entry);
    reserve(byId, lesson.id, entry, "DUPLICATE_LEGACY_ID", "lesson ID");
    reserve(routes, lesson.route, entry, "DUPLICATE_LEGACY_ROUTE", "route");
    reserve(slugs, lesson.slug, entry, "DUPLICATE_LEGACY_SLUG", "slug");
    for (const alias of Array.isArray(lesson.aliases) ? lesson.aliases : []) {
      reserve(aliases, alias, entry, "DUPLICATE_LEGACY_ALIAS", "alias");
    }
    maxLessonNumber = Math.max(maxLessonNumber, Number(lesson.id.slice(4)));
  });

  for (const requiredId of requiredLegacyLessonIds) {
    if (!byId.has(requiredId)) {
      addIssue("LEGACY_REQUIRED_RESERVATION_MISSING", "$.lessons",
        `published lesson reservation "${requiredId}" cannot be removed or reused`);
    }
  }
  for (const [alias, owner] of aliases) {
    const slugOwner = slugs.get(alias);
    if (slugOwner && slugOwner.record.id !== owner.record.id) {
      addIssue("LEGACY_ALIAS_SLUG_COLLISION", owner.path,
        `alias "${alias}" collides with the slug reserved by ${slugOwner.record.id}`);
    }
    const idOwner = byId.get(alias);
    if (idOwner && idOwner.record.id !== owner.record.id) {
      addIssue("LEGACY_ALIAS_ID_COLLISION", owner.path,
        `alias "${alias}" collides with canonical lesson ID ${idOwner.record.id}`);
    }
  }

  return { entries, byId, routes, slugs, aliases, maxLessonNumber, file };
}

function collectCurriculumIds(repositoryRoot) {
  const matrixPath = join(repositoryRoot, "CONTENT_MATRIX.md");
  if (!existsSync(matrixPath)) return new Set();
  return collectCurriculumIdsFromMarkdown(readFileSync(matrixPath, "utf8"));
}

function attachSource(issues, file, lineOffset = 0) {
  return issues.map((entry) => ({
    ...entry,
    file,
    line: Math.max(1, entry.line + lineOffset),
  }));
}

function registerDefinition(definitions, id, file, kind, issues) {
  if (typeof id !== "string") return;
  const first = definitions.get(id);
  if (first) {
    issues.push({
      ...issue("DUPLICATE_CONTENT_ID", "$.id",
        `ID "${id}" is already defined as ${first.kind} in ${first.file}`),
      file,
    });
  } else {
    definitions.set(id, { file, kind });
  }
}

function symlinkAncestors(repositoryRoot, target) {
  const links = [];
  const fromRoot = relative(resolve(repositoryRoot), resolve(target));
  if (isAbsolute(fromRoot) || fromRoot === ".." || fromRoot.startsWith(`..${sep}`)) {
    return links;
  }
  let cursor = resolve(repositoryRoot);
  for (const component of fromRoot.split(sep).filter(Boolean)) {
    cursor = join(cursor, component);
    const cursorStat = lexicalStat(cursor);
    if (!cursorStat) break;
    if (cursorStat.isSymbolicLink()) links.push(cursor);
  }
  return links;
}

export function validateRepositoryStructuredContent(repositoryRoot) {
  const issues = [];
  const schemaDirectory = join(repositoryRoot, "book", "schema");
  const canonicalRootSymlinks = new Set();
  for (const directory of [
    join(repositoryRoot, "book"),
    schemaDirectory,
    join(repositoryRoot, "book", "volumes"),
    join(repositoryRoot, "book", "assessments"),
    join(repositoryRoot, "book", "references"),
    join(repositoryRoot, "book", "labs"),
  ]) {
    const mismatch = exactCaseMismatch(repositoryRoot, directory);
    if (mismatch) {
      issues.push({
        ...issue("CANONICAL_PATH_CASE_MISMATCH", "$",
          `canonical path requested "${mismatch.requested}", but disk entry is "${mismatch.actual}"`),
        file: displayPath(repositoryRoot, directory),
      });
    }
    for (const linkPath of symlinkAncestors(repositoryRoot, directory)) {
      canonicalRootSymlinks.add(resolve(linkPath));
    }
  }
  for (const linkPath of canonicalRootSymlinks) {
    issues.push({
      ...issue("CONTENT_SYMLINK_UNSUPPORTED", "$",
        "canonical book, schema, lesson, assessment, reference, and lab roots must be real directories"),
      file: displayPath(repositoryRoot, linkPath),
    });
  }
  const schemas = {};
  for (const [kind, fileName] of Object.entries(schemaNames)) {
    const filePath = join(schemaDirectory, fileName);
    const schemaCaseMismatch = exactCaseMismatch(repositoryRoot, filePath);
    if (schemaCaseMismatch) {
      issues.push({
        ...issue("CANONICAL_FILE_CASE_MISMATCH", "$",
          `canonical file requested "${schemaCaseMismatch.requested}", but disk entry is "${schemaCaseMismatch.actual}"`),
        file: displayPath(repositoryRoot, filePath),
      });
    }
    const schemaFileStat = lexicalStat(filePath);
    if (schemaFileStat?.isSymbolicLink()) {
      issues.push({
        ...issue("CANONICAL_POLICY_FILE_SYMLINK", "$",
          `${fileName} must be a real regular file, not a symlink`),
        file: displayPath(repositoryRoot, filePath),
      });
      continue;
    }
    if (schemaFileStat && !schemaFileStat.isFile()) {
      issues.push({
        ...issue("SCHEMA_FILE_NOT_REGULAR", "$", `${fileName} must be a regular file`),
        file: displayPath(repositoryRoot, filePath),
      });
      continue;
    }
    if (schemaFileStat
      && !pathIsWithin(realpathSync(repositoryRoot), realpathSync(filePath))) {
      issues.push({
        ...issue("CANONICAL_POLICY_FILE_ESCAPE", "$",
          `${fileName} resolves outside the repository`),
        file: displayPath(repositoryRoot, filePath),
      });
      continue;
    }
    if (!schemaFileStat) {
      issues.push({
        ...issue("SCHEMA_FILE_MISSING", "$", `required schema file ${fileName} is missing`),
        file: displayPath(repositoryRoot, filePath),
      });
      continue;
    }
    const schema = loadJson(filePath, repositoryRoot, issues);
    if (!schema) continue;
    const file = displayPath(repositoryRoot, filePath);
    const schemaIssues = validateSchemaDocument(schema);
    issues.push(...attachSource(schemaIssues, file));
    const baselineMatches = schemaDocumentBaselineSha256[kind]
      === createHash("sha256").update(JSON.stringify(schema)).digest("hex");
    if (!baselineMatches) {
      issues.push({
        ...issue("SCHEMA_BASELINE_DRIFT", "$",
          "schema policy changed without updating the reviewed validator baseline"),
        file,
      });
    }
    if (schema.$schema !== "https://json-schema.org/draft/2020-12/schema"
      || schema.type !== "object") {
      issues.push({
        ...issue("SCHEMA_DOCUMENT_INVALID", "$",
          "schema must declare JSON Schema 2020-12 and an object root"),
        file,
      });
    }
    if (schemaIssues.length === 0
      && baselineMatches
      && schema.$schema === "https://json-schema.org/draft/2020-12/schema"
      && schema.type === "object") schemas[kind] = schema;
  }

  const contentSymlinks = [];
  const lessonFiles = collectFiles(join(repositoryRoot, "book", "volumes"), (filePath) =>
    basename(filePath).toLowerCase() === "lesson.md", contentSymlinks);
  const assessmentFiles = collectFiles(join(repositoryRoot, "book", "assessments"), (filePath) =>
    extname(filePath).toLowerCase() === ".json", contentSymlinks);
  const referenceFiles = collectFiles(join(repositoryRoot, "book", "references"), (filePath) =>
    extname(filePath).toLowerCase() === ".json", contentSymlinks);
  for (const linkPath of contentSymlinks) {
    if (canonicalRootSymlinks.has(resolve(linkPath))) continue;
    issues.push({
      ...issue("CONTENT_SYMLINK_UNSUPPORTED", "$",
        "canonical lesson, assessment, and reference trees cannot contain symlinks or junctions"),
      file: displayPath(repositoryRoot, linkPath),
    });
  }
  const curriculumIds = collectCurriculumIds(repositoryRoot);
  const legacy = validateLegacyContentMap(repositoryRoot, curriculumIds, issues);
  const definitions = new Map();
  const curriculumOwners = new Map();
  const lessons = [];
  const assessments = [];
  const references = [];
  const slugs = new Map();
  const routes = new Map();
  const aliases = new Map();
  const lessonOrders = new Map();
  const volumeRouteSegments = new Map([
    ["00-start-safely", "start"],
    ["01-linux-systems", "linux"],
    ["02-connectivity", "connectivity"],
    ["03-engineering-delivery", "engineering"],
  ]);
  for (const entry of legacy.entries) {
    const id = entry.record.id;
    const owner = { id, file: `${entry.file} (${id})`, legacy: true };
    for (const curriculumId of Array.isArray(entry.record.curriculumIds)
      ? entry.record.curriculumIds : []) {
      if (!curriculumOwners.has(curriculumId)) {
        curriculumOwners.set(curriculumId, owner);
      }
    }
    if (!definitions.has(id)) definitions.set(id, { ...owner, kind: "lesson" });
    if (!routes.has(entry.record.route)) routes.set(entry.record.route, owner);
    if (!slugs.has(entry.record.slug)) slugs.set(entry.record.slug, owner);
    for (const alias of Array.isArray(entry.record.aliases) ? entry.record.aliases : []) {
      if (!aliases.has(alias)) aliases.set(alias, owner);
    }
  }

  if (schemas.lesson) {
    for (const filePath of lessonFiles) {
      const file = displayPath(repositoryRoot, filePath);
      const result = validateLessonDocument(readFileSync(filePath, "utf8"), schemas.lesson);
      issues.push(...attachSource(result.issues, file));
      if (!result.metadata || !isPlainObject(result.metadata)) continue;
      lessons.push({ file, record: result.metadata });
      const legacyEntry = legacy.byId.get(result.metadata.id);
      const existingDefinition = definitions.get(result.metadata.id);
      if (legacyEntry && existingDefinition?.legacy) {
        const identityDrift = [];
        for (const field of ["slug", "route"]) {
          if (result.metadata[field] !== legacyEntry.record[field]) identityDrift.push(field);
        }
        for (const field of ["aliases", "curriculumIds"]) {
          if (!sameStringSet(result.metadata[field], legacyEntry.record[field])) {
            identityDrift.push(field);
          }
        }
        if (identityDrift.length > 0) {
          issues.push({
            ...issue("LEGACY_MIGRATION_IDENTITY_DRIFT", "$.id",
              `migration of ${result.metadata.id} must preserve: ${identityDrift.join(", ")}`),
            file,
          });
        }
        definitions.set(result.metadata.id, { file, kind: "lesson", legacy: false });
      } else {
        registerDefinition(definitions, result.metadata.id, file, "lesson", issues);
        if (lessonIdPattern.test(result.metadata.id)
          && Number(result.metadata.id.slice(4)) <= legacy.maxLessonNumber) {
          issues.push({
            ...issue("LESSON_ID_BELOW_NEW_RANGE", "$.id",
              `new lesson IDs must be greater than LES-${String(legacy.maxLessonNumber).padStart(4, "0")}`),
            file,
          });
        }
      }
      for (const curriculumId of Array.isArray(result.metadata.curriculumIds)
        ? result.metadata.curriculumIds : []) {
        const firstOwner = curriculumOwners.get(curriculumId);
        if (firstOwner && firstOwner.id !== result.metadata.id) {
          issues.push({
            ...issue("DUPLICATE_CURRICULUM_OWNER", "$.curriculumIds",
              `curriculum ID "${curriculumId}" is already owned by ${firstOwner.file}`),
            file,
          });
        } else if (!firstOwner) {
          curriculumOwners.set(curriculumId, {
            id: result.metadata.id, file, legacy: false,
          });
        }
      }
      for (const field of ["diagrams", "commands", "labs", "incidents"]) {
        for (const child of Array.isArray(result.metadata[field]) ? result.metadata[field] : []) {
          registerDefinition(definitions, child?.id, file, field.slice(0, -1), issues);
        }
      }
      if (typeof result.metadata.route === "string") {
        const firstRoute = routes.get(result.metadata.route);
        if (firstRoute && firstRoute.id !== result.metadata.id) {
          issues.push({
            ...issue("DUPLICATE_LESSON_ROUTE", "$.route",
              `route is already used by ${firstRoute.file}`),
            file,
          });
        } else if (!firstRoute) {
          routes.set(result.metadata.route, { id: result.metadata.id, file, legacy: false });
        }
      }
      if (Number.isInteger(result.metadata.order)
        && typeof result.metadata.volume === "string") {
        const orderKey = `${result.metadata.volume}:${result.metadata.order}`;
        const firstOrder = lessonOrders.get(orderKey);
        if (firstOrder && firstOrder.id !== result.metadata.id) {
          issues.push({
            ...issue("DUPLICATE_LESSON_ORDER", "$.order",
              `order is already used in ${result.metadata.volume} by ${firstOrder.file}`),
            file,
          });
        } else if (!firstOrder) {
          lessonOrders.set(orderKey, { id: result.metadata.id, file });
        }
      }
      if (typeof result.metadata.domain === "string"
        && typeof result.metadata.slug === "string"
        && typeof result.metadata.route === "string") {
        const routeSegment = volumeRouteSegments.get(result.metadata.volume)
          ?? result.metadata.domain;
        const expectedRoute = `/book/${routeSegment}/${result.metadata.slug}`;
        if (result.metadata.route !== expectedRoute) {
          issues.push({
            ...issue("LESSON_ROUTE_IDENTITY_MISMATCH", "$.route",
              `route must equal "${expectedRoute}" for this volume and slug`),
            file,
          });
        }
      }
      for (const alias of Array.isArray(result.metadata.aliases)
        ? result.metadata.aliases : []) {
        const firstAlias = aliases.get(alias);
        if (firstAlias && firstAlias.id !== result.metadata.id) {
          issues.push({
            ...issue("DUPLICATE_LESSON_ALIAS", "$.aliases",
              `alias "${alias}" is already used by ${firstAlias.file}`),
            file,
          });
        } else if (!firstAlias) {
          aliases.set(alias, { id: result.metadata.id, file, legacy: false });
        }
      }
      for (const lab of Array.isArray(result.metadata.labs) ? result.metadata.labs : []) {
        if (!isPlainObject(lab) || typeof lab.path !== "string") continue;
        const target = resolve(repositoryRoot, lab.path);
        const allowedRoot = labAllowedRoot(repositoryRoot, lab.path);
        if (!labPathUsesAllowedRoot(lab.path)) {
          issues.push({
            ...issue("LAB_PATH_SCOPE", "$.labs.path",
              "lab path must be a portable directory under phase-##-*, labs/, or book/labs/"),
            file,
          });
        } else if (!pathIsWithin(resolve(repositoryRoot), target)) {
          issues.push({
            ...issue("LAB_PATH_ESCAPE", "$.labs.path", "lab path escapes the repository"),
            file,
          });
        } else if (!existsSync(target)) {
          issues.push({
            ...issue("LAB_PATH_MISSING", "$.labs.path",
              `lab path does not exist: "${lab.path}"`),
            file,
          });
        } else if (!statSync(target).isDirectory()) {
          issues.push({
            ...issue("LAB_PATH_NOT_DIRECTORY", "$.labs.path",
              "lab path must resolve to a dedicated lab directory"),
            file,
          });
        } else if (!pathIsWithin(realpathSync(repositoryRoot), realpathSync(target))) {
          issues.push({
            ...issue("LAB_PATH_SYMLINK_ESCAPE", "$.labs.path",
              "lab path resolves outside the repository through a symlink"),
            file,
          });
        } else if (lstatSync(allowedRoot).isSymbolicLink()) {
          issues.push({
            ...issue("LAB_ALLOWED_ROOT_SYMLINK", "$.labs.path",
              "the selected phase, labs, or book/labs root must be a real directory"),
            file,
          });
        } else if (!pathIsWithin(realpathSync(allowedRoot), realpathSync(target))) {
          issues.push({
            ...issue("LAB_PATH_ALLOWED_ROOT_ESCAPE", "$.labs.path",
              "lab path resolves outside its selected phase, labs, or book/labs root"),
            file,
          });
        } else if (displayPath(repositoryRoot, realpathSync(target)).split("/")
          .some((part) => part.toLocaleLowerCase("en-US") === ".git")) {
          issues.push({
            ...issue("LAB_PATH_GIT_TARGET", "$.labs.path",
              "lab path must not resolve into Git metadata"),
            file,
          });
        } else {
          const mismatch = exactCaseMismatch(repositoryRoot, target);
          if (mismatch) {
            issues.push({
              ...issue("LAB_PATH_CASE_MISMATCH", "$.labs.path",
                `path requested "${mismatch.requested}", but disk entry is "${mismatch.actual}"`),
              file,
            });
          }
        }
      }
      if (typeof result.metadata.slug === "string") {
        const firstSlug = slugs.get(result.metadata.slug);
        if (firstSlug && firstSlug.id !== result.metadata.id) {
          issues.push({
            ...issue("DUPLICATE_LESSON_SLUG", "$.slug",
              `slug is already used by ${firstSlug.file}`),
            file,
          });
        } else if (!firstSlug) {
          slugs.set(result.metadata.slug, { id: result.metadata.id, file, legacy: false });
        }
      }

      const relativeParts = file.split("/");
      const volumeIndex = relativeParts.indexOf("volumes");
      if (relativeParts.length !== 5 || relativeParts[0] !== "book"
        || relativeParts[1] !== "volumes" || relativeParts[4] !== "lesson.md") {
        issues.push({
          ...issue("LESSON_PATH_INVALID", "$",
            "lesson must be book/volumes/<volume>/<lesson-id>-<slug>/lesson.md using exact lowercase names"),
          file,
        });
      }
      if (volumeIndex >= 0 && typeof result.metadata.volume === "string"
        && relativeParts[volumeIndex + 1] !== result.metadata.volume) {
        issues.push({
          ...issue("LESSON_VOLUME_PATH_MISMATCH", "$.volume",
            `metadata volume must match directory "${relativeParts[volumeIndex + 1]}"`),
          file,
        });
      }
      const expectedDirectory = typeof result.metadata.id === "string"
        && typeof result.metadata.slug === "string"
        ? `${result.metadata.id}-${result.metadata.slug}` : null;
      if (volumeIndex >= 0 && expectedDirectory
        && relativeParts[volumeIndex + 2] !== expectedDirectory) {
        issues.push({
          ...issue("LESSON_ID_PATH_MISMATCH", "$.id",
            `lesson directory must be "${expectedDirectory}"`),
          file,
        });
      }
    }
  }

  if (schemas.assessment) {
    for (const filePath of assessmentFiles) {
      const file = displayPath(repositoryRoot, filePath);
      const record = loadJson(filePath, repositoryRoot, issues);
      if (!record) continue;
      issues.push(...attachSource(validateAssessmentRecord(record, schemas.assessment), file));
      const parts = file.split("/");
      if (parts.length !== 4 || parts[0] !== "book" || parts[1] !== "assessments"
        || !slugPattern.test(parts[2])) {
        issues.push({
          ...issue("ASSESSMENT_PATH_INVALID", "$",
            "assessment must be book/assessments/<domain>/<assessment-id>.json"),
          file,
        });
      }
      if (typeof record.id === "string" && basename(filePath) !== `${record.id}.json`) {
        issues.push({
          ...issue("ASSESSMENT_FILENAME_MISMATCH", "$.id",
            `filename must be ${record.id}.json`),
          file,
        });
      }
      assessments.push({ file, record });
      registerDefinition(definitions, record.id, file, "assessment", issues);
    }
  }

  if (schemas.reference) {
    for (const filePath of referenceFiles) {
      const file = displayPath(repositoryRoot, filePath);
      const record = loadJson(filePath, repositoryRoot, issues);
      if (!record) continue;
      issues.push(...attachSource(validateReferenceRecord(record, schemas.reference), file));
      const parts = file.split("/");
      if (parts.length !== 3 || parts[0] !== "book" || parts[1] !== "references") {
        issues.push({
          ...issue("REFERENCE_PATH_INVALID", "$",
            "reference must be book/references/<reference-id>.json"),
          file,
        });
      }
      if (typeof record.id === "string" && basename(filePath) !== `${record.id}.json`) {
        issues.push({
          ...issue("REFERENCE_FILENAME_MISMATCH", "$.id",
            `filename must be ${record.id}.json`),
          file,
        });
      }
      references.push({ file, record });
      registerDefinition(definitions, record.id, file, "reference", issues);
    }
  }

  for (const { file, record } of lessons) {
    for (const curriculumId of Array.isArray(record.curriculumIds) ? record.curriculumIds : []) {
      if (!curriculumIds.has(curriculumId)) {
        issues.push({
          ...issue("CURRICULUM_ID_UNKNOWN", "$.curriculumIds",
            `curriculum ID "${curriculumId}" is not in CONTENT_MATRIX.md`),
          file,
        });
      }
      const curriculumPrefix = typeof curriculumId === "string"
        ? curriculumId.split("-", 1)[0] : "";
      const expectedVolume = canonicalCurriculumVolumeByPrefix[curriculumPrefix];
      if (expectedVolume && record.volume !== expectedVolume) {
        issues.push({
          ...issue("CURRICULUM_VOLUME_HOME_MISMATCH", "$.curriculumIds",
            `curriculum ID "${curriculumId}" belongs to volume "${expectedVolume}", not "${record.volume}"`),
          file,
        });
      }
    }
    for (const prerequisite of Array.isArray(record.prerequisiteCurriculumIds)
      ? record.prerequisiteCurriculumIds : []) {
      if (!curriculumIds.has(prerequisite)) {
        issues.push({
          ...issue("PREREQUISITE_CURRICULUM_UNKNOWN", "$.prerequisiteCurriculumIds",
            `prerequisite curriculum ID "${prerequisite}" is not in CONTENT_MATRIX.md`),
          file,
        });
      }
    }
    for (const prerequisite of Array.isArray(record.prerequisiteLessonIds)
      ? record.prerequisiteLessonIds : []) {
      const definition = definitions.get(prerequisite);
      if (!definition || definition.kind !== "lesson") {
        issues.push({
          ...issue("PREREQUISITE_LESSON_UNKNOWN", "$.prerequisiteLessonIds",
            `prerequisite lesson "${prerequisite}" has no lesson or legacy reservation`),
          file,
        });
      }
    }
    for (const assessmentId of Array.isArray(record.assessmentIds) ? record.assessmentIds : []) {
      const definition = definitions.get(assessmentId);
      if (!definition || definition.kind !== "assessment") {
        issues.push({
          ...issue("ASSESSMENT_UNRESOLVED", "$.assessmentIds",
            `assessment "${assessmentId}" has no assessment record`),
          file,
        });
      }
      const assessment = assessments.find((candidate) => candidate.record.id === assessmentId);
      if (assessment && assessment.record.lessonId !== record.id) {
        issues.push({
          ...issue("ASSESSMENT_OWNER_MISMATCH", "$.assessmentIds",
            `assessment "${assessmentId}" belongs to "${assessment.record.lessonId}", not "${record.id}"`),
          file,
        });
      }
    }
    for (const referenceId of Array.isArray(record.referenceIds) ? record.referenceIds : []) {
      const definition = definitions.get(referenceId);
      if (!definition || definition.kind !== "reference") {
        issues.push({
          ...issue("REFERENCE_UNRESOLVED", "$.referenceIds",
            `reference "${referenceId}" has no reference record`),
          file,
        });
      }
      const reference = references.find((candidate) => candidate.record.id === referenceId);
      if (reference && !reference.record.lessonIds?.includes(record.id)) {
        issues.push({
          ...issue("REFERENCE_BACKLINK_MISSING", "$.referenceIds",
            `reference "${referenceId}" does not list lesson "${record.id}"`),
          file,
        });
      }
    }
  }

  for (const { file, record } of assessments) {
    const definition = definitions.get(record.lessonId);
    if (!definition || definition.kind !== "lesson") {
      issues.push({
        ...issue("ASSESSMENT_LESSON_UNKNOWN", "$.lessonId",
          `lesson "${record.lessonId}" has no structured lesson record`),
        file,
      });
    }
    const lesson = lessons.find((candidate) => candidate.record.id === record.lessonId);
    if (lesson && !lesson.record.assessmentIds?.includes(record.id)) {
      issues.push({
        ...issue("ASSESSMENT_BACKLINK_MISSING", "$.id",
          `structured lesson "${record.lessonId}" does not list this assessment`),
        file,
      });
    }
    const legacyLesson = legacy.byId.get(record.lessonId);
    const expectedDomain = lesson?.record.domain
      ?? (typeof legacyLesson?.record.route === "string"
        ? legacyLesson.record.route.split("/")[2] : null);
    const assessmentParts = file.split("/");
    const actualDomain = assessmentParts.length === 4
      && assessmentParts[0] === "book" && assessmentParts[1] === "assessments"
      ? assessmentParts[2] : null;
    if (expectedDomain && actualDomain && actualDomain !== expectedDomain) {
      issues.push({
        ...issue("ASSESSMENT_DOMAIN_MISMATCH", "$",
          `assessment directory must match owner domain "${expectedDomain}"`),
        file,
      });
    }
  }

  for (const { file, record } of references) {
    for (const lessonId of Array.isArray(record.lessonIds) ? record.lessonIds : []) {
      const definition = definitions.get(lessonId);
      if (!definition || definition.kind !== "lesson") {
        issues.push({
          ...issue("REFERENCE_LESSON_UNKNOWN", "$.lessonIds",
            `lesson "${lessonId}" has no structured lesson record`),
          file,
        });
        continue;
      }
      const lesson = lessons.find((candidate) => candidate.record.id === lessonId);
      if (lesson && !lesson.record.referenceIds?.includes(record.id)) {
        issues.push({
          ...issue("REFERENCE_LESSON_BACKLINK_MISSING", "$.lessonIds",
            `lesson "${lessonId}" does not list reference "${record.id}"`),
          file,
        });
      }
    }
  }

  for (const [alias, owner] of aliases) {
    if (definitions.has(alias)) {
      issues.push({
        ...issue("ALIAS_ID_COLLISION", "$.aliases",
          `alias "${alias}" collides with a canonical content ID`),
        file: owner.file,
      });
    }
    const slugOwner = slugs.get(alias);
    if (slugOwner && slugOwner.id !== owner.id) {
      issues.push({
        ...issue("ALIAS_SLUG_COLLISION", "$.aliases",
          `alias "${alias}" collides with the slug owned by ${slugOwner.file}`),
        file: owner.file,
      });
    }
  }

  const lessonById = new Map(lessons
    .filter(({ record }) => lessonIdPattern.test(record.id))
    .map(({ record }) => [record.id, record]));
  const visiting = new Set();
  const visited = new Set();
  function visitLesson(lessonId, path) {
    if (visiting.has(lessonId)) {
      const lesson = lessons.find((candidate) => candidate.record.id === lessonId);
      issues.push({
        ...issue("PREREQUISITE_CYCLE", "$.prerequisiteLessonIds",
          `prerequisite cycle detected: ${[...path, lessonId].join(" -> ")}`),
        file: lesson?.file ?? "book/volumes",
      });
      return;
    }
    if (visited.has(lessonId)) return;
    const lesson = lessonById.get(lessonId);
    if (!lesson) return;
    visiting.add(lessonId);
    for (const prerequisite of Array.isArray(lesson.prerequisiteLessonIds)
      ? lesson.prerequisiteLessonIds : []) {
      visitLesson(prerequisite, [...path, lessonId]);
    }
    visiting.delete(lessonId);
    visited.add(lessonId);
  }
  for (const lessonId of lessonById.keys()) visitLesson(lessonId, []);

  issues.sort((left, right) => (left.file ?? "").localeCompare(right.file ?? "")
    || left.line - right.line || left.code.localeCompare(right.code)
    || left.path.localeCompare(right.path));
  return {
    issues,
    metrics: {
      schemaFiles: Object.keys(schemas).length,
      lessons: lessonFiles.length,
      assessments: assessmentFiles.length,
      references: referenceFiles.length,
      legacyLessons: legacy.entries.length,
    },
  };
}

export function stableIdIsValid(value) {
  return typeof value === "string" && stableIdPattern.test(value);
}
