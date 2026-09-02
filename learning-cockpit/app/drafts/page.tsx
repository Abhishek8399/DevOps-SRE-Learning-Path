import Link from "next/link";
import { createStagedDraftSearchDocuments } from "../search/staged-draft-search";
import StagedDraftLibrary from "../staged-draft-library";
import { compactStagedDraftSearchText } from "../staged-draft-library-filter-core";
import { groupStagedDrafts } from "../staged-draft-library-core";
import { stagedDrafts } from "../staged-draft.server";

export default function StagedDraftLibraryPage() {
  const documentsByHref = new Map(createStagedDraftSearchDocuments(stagedDrafts).map((document) => [document.href, document]));
  const volumes = groupStagedDrafts(stagedDrafts).map((volume) => ({
    id: volume.id,
    number: volume.number,
    title: volume.title,
    drafts: volume.drafts.map((draft) => {
      const document = documentsByHref.get(`/drafts/${draft.slug}`);
      return {
        slug: draft.slug,
        id: draft.lesson.metadata.id,
        title: draft.lesson.title,
        searchText: compactStagedDraftSearchText([
          draft.slug,
          draft.lesson.metadata.id,
          draft.lesson.title,
          ...(document?.fields.flatMap((field) => field.values) ?? []),
        ]),
      };
    }),
  }));

  return <main className="cockpit-shell" id="main-content"><nav className="breadcrumbs" aria-label="Breadcrumb"><Link href="/">Home</Link><span>/</span><Link href="/book">Knowledge library</Link><span>/</span><b>Extended chapters</b></nav><header className="practice-page-heading"><p className="eyebrow">EXTENDED CHAPTER LIBRARY / REVIEW PENDING</p><h1>Read every authored advanced chapter while its acceptance evidence is completed.</h1><p>These are complete teaching chapters from the repository, not hidden work files. They remain separate from the canonical shelf because a chapter can explain a real mechanism without claiming its local lab, provider runtime, production behavior, or learner mastery has been verified.</p></header><StagedDraftLibrary volumes={volumes} /></main>;
}
