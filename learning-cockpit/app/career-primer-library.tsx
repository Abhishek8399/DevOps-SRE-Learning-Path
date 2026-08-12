"use client";

import Link from "next/link";
import { useMemo, useRef, useState } from "react";
import { filterCareerPrimerLibrary, type CareerPrimerLibraryItem } from "./career-primer-library-core";

export default function CareerPrimerLibrary({ primers }: { primers: readonly CareerPrimerLibraryItem[] }) {
  const [query, setQuery] = useState("");
  const input = useRef<HTMLInputElement>(null);
  const matches = useMemo(() => filterCareerPrimerLibrary(primers, query), [primers, query]);
  const active = query.trim().length > 0;

  return <section className="primer-library" aria-labelledby="career-library-title">
    <div className="section-heading">
      <div>
        <p className="eyebrow">COMPLETE CAREER LIBRARY</p>
        <h2 id="career-library-title">Validated local primers, readable in the manual.</h2>
        <p className="section-intro">These chapters are generated directly from version-controlled <code>career/</code> sources. Filter this shelf locally by a title or term; the full offline search remains available for symptoms and commands.</p>
      </div>
    </div>
    <form className="primer-library-filter" onSubmit={(event) => event.preventDefault()} role="search">
      <label htmlFor="career-primer-filter">Filter career chapters</label>
      <div><input autoComplete="off" id="career-primer-filter" maxLength={120} onChange={(event) => setQuery(event.target.value)} placeholder="Try: Kubernetes, incident, Terraform, data" ref={input} type="search" value={query} />{active ? <button onClick={() => { setQuery(""); input.current?.focus(); }} type="button">Clear</button> : null}</div>
      <p aria-live="polite">{active ? `${matches.length} of ${primers.length} chapters match.` : `${primers.length} local chapters available.`}</p>
    </form>
    {matches.length > 0 ? <div className="primer-library-grid">
      {matches.map((primer) => <Link className="primer-library-card" href={`/career/${primer.slug}`} key={primer.slug}><span>FIELD MANUAL</span><strong>{primer.title}</strong><small>Open the local chapter -&gt;</small></Link>)}
    </div> : <div className="primer-library-empty"><strong>No local chapter matches that wording.</strong><p>Try one mechanism or role term, or use the full manual search for a symptom or command.</p></div>}
  </section>;
}
