declare module "*.md?raw" {
  const content: string;
  export default content;
}

declare module "virtual:book-lesson/*" {
  const content: string;
  export default content;
}

declare module "virtual:career-primers" {
  export const generatedCareerPrimerSources: readonly { slug: string; title: string; source: string }[];
}

declare module "virtual:staged-drafts" {
  export const generatedStagedDraftSources: readonly { slug: string; source: string; assessments: readonly unknown[]; references: readonly unknown[] }[];
}
