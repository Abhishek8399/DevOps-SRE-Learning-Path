import { notFound } from "next/navigation";
import StagedDraftArticle from "../../staged-draft-article";
import { findStagedDraft, stagedDrafts } from "../../staged-draft.server";

export function generateStaticParams() { return stagedDrafts.map((draft) => ({ draft: draft.slug })); }

export default async function StagedDraftPage({ params }: { params: Promise<{ draft: string }> }) {
  const { draft: slug } = await params;
  const draft = findStagedDraft(slug);
  if (!draft) notFound();
  return <main className="cockpit-shell" id="main-content"><StagedDraftArticle draft={draft} /></main>;
}
