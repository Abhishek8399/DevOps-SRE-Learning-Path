export const allowedPlanStatuses = Object.freeze([
  "PENDING",
  "IN_PROGRESS",
  "BLOCKED",
  "REVIEW_REQUIRED",
  "COMPLETE",
]);

const legacyStatuses = Object.freeze([
  "COMMITTED",
  "WORKTREE",
  "PARTIAL",
  "PLANNED",
  "DEFERRED",
]);

function cells(line) {
  return line.trim().replace(/^\|/, "").replace(/\|$/, "").split("|").map((cell) => cell.trim());
}

function statusValue(cell) {
  return cell.match(/^`([A-Z_]+)`$/)?.[1];
}

export function validateMasterPlan(source) {
  const issues = [];
  const ids = new Map();
  const definitions = new Map();
  const taskStatuses = new Map(allowedPlanStatuses.map((status) => [status, 0]));
  const lines = source.replace(/\r\n/g, "\n").split("\n");

  lines.forEach((line, index) => {
    const lineNumber = index + 1;
    for (const legacy of legacyStatuses) {
      if (line.includes(`\`${legacy}\``)) issues.push({ line: lineNumber, message: `legacy status ${legacy} is not allowed` });
    }

    const definition = line.match(/^\| `([A-Z_]+)` \| .+ \|$/);
    if (definition && allowedPlanStatuses.includes(definition[1])) {
      definitions.set(definition[1], (definitions.get(definition[1]) ?? 0) + 1);
    }

    if (!/^\| `PLAN-[A-Z0-9-]+` \|/.test(line)) return;
    const row = cells(line);
    const id = row[0].replaceAll("`", "");
    const priorLine = ids.get(id);
    if (priorLine) issues.push({ line: lineNumber, message: `duplicate task id ${id}; first declared on line ${priorLine}` });
    else ids.set(id, lineNumber);

    const milestone = id.startsWith("PLAN-MS-");
    const expectedCells = milestone ? 4 : 7;
    if (row.length !== expectedCells) {
      issues.push({ line: lineNumber, message: `${id} has ${row.length} cells; expected ${expectedCells}` });
      return;
    }
    if (row.some((cell) => cell.length === 0)) issues.push({ line: lineNumber, message: `${id} contains an empty required cell` });
    if (!milestone && !/^P[0-3]$/.test(row[1])) issues.push({ line: lineNumber, message: `${id} has invalid priority ${row[1]}` });

    const status = statusValue(row[milestone ? 3 : 4]);
    if (!status || !allowedPlanStatuses.includes(status)) {
      issues.push({ line: lineNumber, message: `${id} has an invalid status` });
    } else {
      taskStatuses.set(status, taskStatuses.get(status) + 1);
    }
  });

  for (const status of allowedPlanStatuses) {
    if (definitions.get(status) !== 1) {
      issues.push({ line: 0, message: `status vocabulary must define ${status} exactly once` });
    }
  }
  if (ids.size === 0) issues.push({ line: 0, message: "master plan contains no PLAN-* task rows" });

  return {
    issues,
    taskCount: ids.size,
    statusCounts: Object.fromEntries(taskStatuses),
  };
}
