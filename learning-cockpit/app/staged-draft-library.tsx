"use client";

import Link from "next/link";
import { useMemo, useRef, useState } from "react";
import { filterStagedDraftLibrary, type StagedDraftFilterItem } from "./staged-draft-library-filter-core";

export type StagedDraftFilterVolume = Readonly<{
  id: string;
  number: string;
  title: string;
  drafts: readonly StagedDraftFilterItem[];
}>;

export default function StagedDraftLibrary({ volumes }: { volumes: readonly StagedDraftFilterVolume[] }) {
  const [query, setQuery] = useState("");
  const input = useRef<HTMLInputElement>(null);
  const total = useMemo(() => volumes.reduce((sum, volume) => sum + volume.drafts.length, 0), [volumes]);
  const active = query.trim().length > 0;
  const visibleVolumes = useMemo(() => volumes.map((volume) => ({
    ...volume,
    drafts: filterStagedDraftLibrary(volume.drafts, query),
  })).filter((volume) => volume.drafts.length > 0), [query, volumes]);
  const matchCount = visibleVolumes.reduce((sum, volume) => sum + volume.drafts.length, 0);

  return <section className="primer-library" aria-labelledby="staged-draft-list">
    <div className="section-heading"><div><p className="eyebrow">{total} CHAPTERS / {volumes.length} VOLUMES</p><h2 id="staged-draft-list">Follow the same system journey as the field manual.</h2><p className="section-intro">Use this shelf for reading and question-driven learning. The canonical library remains the source of validated, registered lessons.</p></div></div>
    <form className="primer-library-filter" onSubmit={(event) => event.preventDefault()} role="search">
      <label htmlFor="staged-draft-filter">Filter extended chapters</label>
      <div><input autoComplete="off" id="staged-draft-filter" maxLength={160} onChange={(event) => setQuery(event.target.value)} placeholder="Try: Terraform, ENOSPC, kubectl, SLO" ref={input} type="search" value={query} />{active ? <button onClick={() => { setQuery(""); input.current?.focus(); }} type="button">Clear</button> : null}</div>
      <p aria-live="polite">{active ? `${matchCount} of ${total} chapters match across ${visibleVolumes.length} volumes.` : `${total} extended chapters available.`}</p>
    </form>
    {visibleVolumes.length > 0 ? <>
      <nav aria-label="Jump to an extended-study volume" className="draft-volume-index">{visibleVolumes.map((volume) => <a href={`#draft-volume-${volume.number}`} key={volume.id}><span>VOLUME {volume.number}</span><strong>{volume.title}</strong><small>{volume.drafts.length} chapters</small></a>)}</nav>
      {visibleVolumes.map((volume) => <section aria-labelledby={`draft-volume-${volume.number}`} className="primer-library" key={volume.id}><div className="section-heading"><div><p className="eyebrow">VOLUME {volume.number} / {volume.drafts.length} {active ? "MATCHING " : ""}STAGED CHAPTERS</p><h2 id={`draft-volume-${volume.number}`}>{volume.title}</h2></div></div><div className="primer-library-grid">{volume.drafts.map((draft) => <Link className="primer-library-card" href={`/drafts/${draft.slug}`} key={draft.slug}><span>{draft.id} · STAGED</span><strong>{draft.title}</strong><small>Open the reading preview -&gt;</small></Link>)}</div></section>)}
    </> : <div className="primer-library-empty"><strong>No extended chapter matches all those words.</strong><p>Try one mechanism, incident symptom, command, or lesson ID—for example <code>inode</code>, <code>timeout</code>, <code>kubectl</code>, or <code>LES-0042</code>.</p></div>}
  </section>;
}
