export type EvidenceExport = Readonly<{ route: string; note: string; exportedAt: string }>;

const SENSITIVE_LINE = /^(\s*(?:password|passphrase|secret|token|api[_ -]?key|private[_ -]?key|authorization|cookie)\s*[:=]).*$/i;

export function sanitizeEvidenceNote(note: string): string {
  return note.split("\n").map((line) => line.replace(SENSITIVE_LINE, (_match, prefix: string) => `${prefix} [REDACTED]`)).join("\n").slice(0, 2000);
}

export function createEvidenceExport(route: string, note: string, exportedAt = new Date().toISOString()): EvidenceExport {
  return { route: route.slice(0, 500), note: sanitizeEvidenceNote(note), exportedAt };
}

export function evidenceAsMarkdown(evidence: EvidenceExport): string {
  return ["# Local learning evidence", "", `- Route: ${evidence.route}`, `- Exported: ${evidence.exportedAt}`, "- Scope: private reading note only; not mastery evidence", "", "## Note", "", evidence.note || "(empty note)", ""].join("\n");
}

export function evidenceAsJson(evidence: EvidenceExport): string { return JSON.stringify(evidence, null, 2) + "\n"; }
