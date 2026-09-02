import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { validateMasterPlan } from "./lib/master-plan-validator.mjs";

const repositoryRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const planPath = path.join(repositoryRoot, "MASTER_PLAN.md");
const result = validateMasterPlan(fs.readFileSync(planPath, "utf8"));

for (const issue of result.issues) {
  console.error(`MASTER_PLAN.md:${issue.line || 1}: ${issue.message}`);
}

const counts = Object.entries(result.statusCounts).map(([status, count]) => `${status.toLowerCase()}=${count}`).join(" ");
if (result.issues.length > 0) {
  console.error(`FAIL master plan tasks=${result.taskCount} issues=${result.issues.length} ${counts}`);
  process.exitCode = 1;
} else {
  console.log(`PASS master plan tasks=${result.taskCount} ${counts}`);
}
