import { generatedCareerPrimerSources } from "virtual:career-primers";
import { parseMarkdownBlocks } from "./lessons/structured-lesson-parser";

export type CareerPrimer = Readonly<{ slug: string; title: string; blocks: ReturnType<typeof parseMarkdownBlocks> }>;

export const careerPrimers: readonly CareerPrimer[] = generatedCareerPrimerSources.map((primer) => ({
  slug: primer.slug,
  title: primer.title,
  blocks: parseMarkdownBlocks(primer.source.replace(/^#\s+.+\n+/, "")),
}));

export function findCareerPrimer(slug: string): CareerPrimer | undefined {
  return careerPrimers.find((primer) => primer.slug === slug);
}
