const DAY_MS = 24 * 60 * 60 * 1000;

export function parseIsoDate(value, label = "date") {
  if (!/^\d{4}-\d{2}-\d{2}$/.test(value)) {
    throw new Error(`${label} must use YYYY-MM-DD`);
  }
  const date = new Date(`${value}T00:00:00Z`);
  if (Number.isNaN(date.valueOf()) || date.toISOString().slice(0, 10) !== value) {
    throw new Error(`${label} is not a real calendar date`);
  }
  return date;
}

export function evaluateReferenceFreshness(entries, { asOf, warnDays = 90 }) {
  if (!Number.isInteger(warnDays) || warnDays < 0 || warnDays > 3650) {
    throw new Error("warnDays must be an integer from 0 through 3650");
  }
  const asOfDate = parseIsoDate(asOf, "asOf");
  const errors = [];
  const seenIds = new Map();
  const rows = [];

  for (const entry of entries) {
    const { record, path, scope } = entry;
    if (entry.preflightError) {
      errors.push(`${path}: ${entry.preflightError}`);
      continue;
    }
    if (!record || typeof record !== "object" || Array.isArray(record)) {
      errors.push(`${path}: reference must be a JSON object`);
      continue;
    }
    if (typeof record.id !== "string" || !/^REF-\d{4}$/.test(record.id)) {
      errors.push(`${path}: invalid reference id`);
      continue;
    }
    const priorPath = seenIds.get(record.id);
    if (priorPath) errors.push(`${path}: duplicate ${record.id}; first defined at ${priorPath}`);
    else seenIds.set(record.id, path);

    let reviewedDate;
    let reviewAfterDate;
    try {
      reviewedDate = parseIsoDate(record.lastReviewed, `${path} lastReviewed`);
      reviewAfterDate = parseIsoDate(record.reviewAfter, `${path} reviewAfter`);
    } catch (error) {
      errors.push(error.message);
      continue;
    }
    if (reviewAfterDate <= reviewedDate) {
      errors.push(`${path}: reviewAfter must be later than lastReviewed`);
      continue;
    }
    if (reviewedDate > asOfDate) {
      errors.push(`${path}: lastReviewed ${record.lastReviewed} is after audit date ${asOf}`);
      continue;
    }

    const daysUntilReview = Math.round((reviewAfterDate - asOfDate) / DAY_MS);
    const status = daysUntilReview < 0 ? "overdue" : daysUntilReview <= warnDays ? "due-soon" : "current";
    rows.push({
      id: record.id,
      path,
      scope,
      url: typeof record.url === "string" ? record.url : "",
      lastReviewed: record.lastReviewed,
      reviewAfter: record.reviewAfter,
      daysUntilReview,
      status,
    });
  }

  rows.sort((left, right) => left.reviewAfter.localeCompare(right.reviewAfter) || left.id.localeCompare(right.id));
  const rowsByUrl = new Map();
  for (const row of rows.filter((candidate) => candidate.url)) {
    rowsByUrl.set(row.url, [...(rowsByUrl.get(row.url) ?? []), row]);
  }
  const duplicateUrls = [...rowsByUrl.entries()]
    .filter(([, matches]) => matches.length > 1)
    .map(([url, matches]) => ({ url, count: matches.length, ids: matches.map((row) => row.id).sort() }))
    .sort((left, right) => right.count - left.count || left.url.localeCompare(right.url));

  return {
    asOf,
    warnDays,
    summary: {
      records: rows.length,
      canonical: rows.filter((row) => row.scope === "canonical").length,
      staged: rows.filter((row) => row.scope === "staged").length,
      current: rows.filter((row) => row.status === "current").length,
      dueSoon: rows.filter((row) => row.status === "due-soon").length,
      overdue: rows.filter((row) => row.status === "overdue").length,
      duplicateUrlGroups: duplicateUrls.length,
      errors: errors.length,
    },
    rows,
    duplicateUrls,
    errors,
  };
}
