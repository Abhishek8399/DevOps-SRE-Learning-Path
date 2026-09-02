import assert from "node:assert/strict";
import test from "node:test";
import { evaluateReferenceFreshness, parseIsoDate } from "../lib/reference-freshness.mjs";

function entry(id, lastReviewed, reviewAfter, scope = "canonical", url = `https://example.com/${id}`) {
  return { path: `${scope}/${id}.json`, scope, record: { id, lastReviewed, reviewAfter, url } };
}

test("ISO dates reject impossible calendar values", () => {
  assert.throws(() => parseIsoDate("2026-02-29"), /real calendar date/);
  assert.throws(() => parseIsoDate("02-28-2026"), /YYYY-MM-DD/);
  assert.equal(parseIsoDate("2028-02-29").toISOString().slice(0, 10), "2028-02-29");
});

test("reference freshness separates overdue, due-soon, and current records", () => {
  const result = evaluateReferenceFreshness([
    entry("REF-0001", "2026-01-01", "2026-08-31"),
    entry("REF-0002", "2026-01-01", "2026-09-02", "staged"),
    entry("REF-0003", "2026-01-01", "2026-10-01"),
    entry("REF-0004", "2026-01-01", "2026-12-15"),
  ], { asOf: "2026-09-02", warnDays: 30 });
  assert.deepEqual(result.summary, { records: 4, canonical: 3, staged: 1, current: 1, dueSoon: 2, overdue: 1, duplicateUrlGroups: 0, errors: 0 });
  assert.deepEqual(result.rows.map((row) => [row.id, row.status, row.daysUntilReview]), [
    ["REF-0001", "overdue", -2],
    ["REF-0002", "due-soon", 0],
    ["REF-0003", "due-soon", 29],
    ["REF-0004", "current", 104],
  ]);
});

test("reference freshness reports duplicate IDs, duplicate URLs, and future review claims", () => {
  const sharedUrl = "https://example.com/shared";
  const result = evaluateReferenceFreshness([
    entry("REF-0001", "2026-01-01", "2026-12-01", "canonical", sharedUrl),
    entry("REF-0001", "2026-01-01", "2026-12-01", "staged", sharedUrl),
    entry("REF-0002", "2026-09-03", "2026-12-01"),
  ], { asOf: "2026-09-02", warnDays: 30 });
  assert.equal(result.summary.errors, 2);
  assert.match(result.errors.join("\n"), /duplicate REF-0001/);
  assert.match(result.errors.join("\n"), /after audit date/);
  assert.deepEqual(result.duplicateUrls, [{ url: sharedUrl, count: 2, ids: ["REF-0001", "REF-0001"] }]);
});

test("reference freshness rejects invalid windows and collection errors", () => {
  const result = evaluateReferenceFreshness([
    entry("REF-0001", "2026-05-01", "2026-05-01"),
    { path: "staged/broken.json", scope: "staged", record: null, preflightError: "invalid JSON" },
  ], { asOf: "2026-09-02", warnDays: 30 });
  assert.equal(result.summary.records, 0);
  assert.equal(result.summary.errors, 2);
  assert.match(result.errors.join("\n"), /reviewAfter must be later/);
  assert.match(result.errors.join("\n"), /invalid JSON/);
  assert.throws(() => evaluateReferenceFreshness([], { asOf: "2026-09-02", warnDays: -1 }), /warnDays/);
});
