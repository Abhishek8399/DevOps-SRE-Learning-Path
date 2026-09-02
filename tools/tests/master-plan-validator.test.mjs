import assert from "node:assert/strict";
import test from "node:test";
import { allowedPlanStatuses, validateMasterPlan } from "../lib/master-plan-validator.mjs";

const vocabulary = allowedPlanStatuses.map((status) => `| \`${status}\` | Meaning for ${status}. |`).join("\n");

test("a milestone and a fully described task use the governing status vocabulary", () => {
  const source = `${vocabulary}\n| \`PLAN-MS-00\` | Milestone | Exit condition | \`COMPLETE\` |\n| \`PLAN-GOV-001\` | P0 | Control | None | \`IN_PROGRESS\` | Acceptance | Verification |\n`;
  const result = validateMasterPlan(source);
  assert.deepEqual(result.issues, []);
  assert.equal(result.taskCount, 2);
  assert.equal(result.statusCounts.COMPLETE, 1);
  assert.equal(result.statusCounts.IN_PROGRESS, 1);
});

test("legacy statuses, duplicate IDs, invalid priorities, and incomplete rows fail", () => {
  const source = `${vocabulary}\n| \`PLAN-GOV-001\` | P0 | Control | None | \`PARTIAL\` | Acceptance | Verification |\n| \`PLAN-GOV-001\` | P9 | Control | None | \`PENDING\` | Acceptance |\n`;
  const messages = validateMasterPlan(source).issues.map((issue) => issue.message).join("\n");
  assert.match(messages, /legacy status PARTIAL/);
  assert.match(messages, /invalid status/);
  assert.match(messages, /duplicate task id/);
  assert.match(messages, /has 6 cells; expected 7/);
});

test("every allowed status must have exactly one vocabulary definition", () => {
  const source = `${vocabulary}\n| \`COMPLETE\` | Duplicate. |\n| \`PLAN-MS-00\` | Milestone | Exit condition | \`COMPLETE\` |\n`;
  assert.match(validateMasterPlan(source).issues.map((issue) => issue.message).join("\n"), /define COMPLETE exactly once/);
});
