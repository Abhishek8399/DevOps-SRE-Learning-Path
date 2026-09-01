export type StagedDraftLibraryItem = Readonly<{
  lesson: Readonly<{ metadata: Readonly<{ volume: string }> }>;
}>;

const volumeTitles: Readonly<Record<string, string>> = {
  "00-start-safely": "Start safely",
  "01-linux-systems": "Linux systems",
  "04-reliability-operations": "Reliability and operations",
  "05-infrastructure-platforms": "Infrastructure and platforms",
  "06-state-distributed-systems": "State and distributed systems",
  "07-ai-engineering": "AI engineering",
  "08-security-engineering": "Security engineering",
  "09-private-cloud": "Private cloud",
  "10-architecture-leadership": "Architecture and leadership",
  "11-capstones": "Capstones",
};

export type StagedDraftVolume<T extends StagedDraftLibraryItem> = Readonly<{
  id: string;
  number: string;
  title: string;
  drafts: readonly T[];
}>;

export function groupStagedDrafts<T extends StagedDraftLibraryItem>(
  drafts: readonly T[],
): readonly StagedDraftVolume<T>[] {
  const byVolume = new Map<string, T[]>();
  for (const draft of drafts) {
    const volume = draft.lesson.metadata.volume;
    byVolume.set(volume, [...(byVolume.get(volume) ?? []), draft]);
  }
  return [...byVolume.entries()]
    .sort(([left], [right]) => left.localeCompare(right))
    .map(([id, volumeDrafts]) => ({
      id,
      number: id.slice(0, 2),
      title: volumeTitles[id] ?? id.replace(/^\d+-/, "").replace(/-/g, " "),
      drafts: volumeDrafts,
    }));
}
