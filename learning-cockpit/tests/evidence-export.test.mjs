import test from "node:test";
import assert from "node:assert/strict";
import { createEvidenceExport, evidenceAsJson, evidenceAsMarkdown, sanitizeEvidenceNote } from "../app/evidence-export.ts";

test("redacts common secret-like lines without changing ordinary notes", () => {
  const result = sanitizeEvidenceNote("Hypothesis: inode exhaustion\napi-key=do-not-export\nNext: run df -i");
  assert.match(result, /Hypothesis: inode exhaustion/);
  assert.match(result, /api-key= \[REDACTED\]/);
  assert.match(result, /Next: run df -i/);
  assert.doesNotMatch(result, /do-not-export/);
});

test("exports stable markdown and JSON with a non-mastery boundary", () => {
  const evidence = createEvidenceExport("/book/linux/storage", "Teach-back note", "2026-08-11T00:00:00.000Z");
  assert.match(evidenceAsMarkdown(evidence), /not mastery evidence/);
  assert.deepEqual(JSON.parse(evidenceAsJson(evidence)), evidence);
});
