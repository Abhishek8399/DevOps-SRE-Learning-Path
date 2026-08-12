import type { SearchDocument } from "./search-index";

export type CareerPrimerSearchSource = Readonly<{
  slug: string;
  title: string;
  source: string;
}>;

function unique(values: readonly string[]): string[] {
  return [...new Set(values.map((value) => value.trim()).filter(Boolean))];
}

function compact(value: string): string {
  return value.replace(/\s+/g, " ").trim();
}

function markdownText(value: string): string {
  return compact(value
    .replace(/`([^`]+)`/g, "$1")
    .replace(/\[([^\]]+)\]\([^)]*\)/g, "$1")
    .replace(/^[-*>#\d.\s]+/u, ""));
}

function firstParagraph(source: string): string {
  const paragraph = source.split(/\r?\n\s*\r?\n/u).find((part) =>
    !part.trimStart().startsWith("#"));
  return markdownText(paragraph ?? "").slice(0, 220);
}

export function createCareerPrimerSearchDocuments(
  primers: readonly CareerPrimerSearchSource[],
): readonly SearchDocument[] {
  return primers.map((primer, index) => {
    const lines = primer.source.split(/\r?\n/u);
    const headings = unique(lines
      .filter((line) => /^#{2,4}\s+/.test(line))
      .map((line) => markdownText(line))
      .slice(0, 48));
    const commands = unique([...primer.source.matchAll(/`([^`\r\n]+)`/g)]
      .map((match) => compact(match[1]))
      .filter((value) => value.length > 1 && value.length <= 180)
      .slice(0, 48));
    const guidance = unique(lines
      .filter((line) => line.trim().length > 40 && !line.trimStart().startsWith("#"))
      .map(markdownText)
      .filter((line) => line.length > 20)
      .slice(0, 64));

    return {
      id: `career-${primer.slug}`,
      number: String(index + 1).padStart(2, "0"),
      volumeNumber: "06",
      volumeTitle: "Career field manual",
      title: primer.title,
      subtitle: firstParagraph(primer.source) || "Version-controlled local career field-manual chapter.",
      href: `/career/${primer.slug}`,
      fields: [
        { category: "Title", values: [primer.title, primer.slug], weight: 14 },
        { category: "Term", values: headings, weight: 9 },
        { category: "Command", values: commands, weight: 8 },
        { category: "Lesson guidance", values: guidance, weight: 4 },
      ],
    };
  });
}
