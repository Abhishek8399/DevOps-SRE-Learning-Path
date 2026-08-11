import Link from "next/link";
import { careerPrimers } from "../career-primer.server";
import CareerOverview from "../career-overview";

export default function CareerPage() {
  return (
    <main className="cockpit-shell" id="main-content">
      <nav className="breadcrumbs" aria-label="Breadcrumb"><Link href="/">Home</Link><span>/</span><b>Career map</b></nav>
      <header className="practice-page-heading">
        <p className="eyebrow">ROLE-DRIVEN LEARNING MAP</p>
        <h1>Build one dependable foundation, then choose your specialist direction.</h1>
        <p>Use the job-profile matrix to choose emphasis, not to skip fundamentals. The same loop—impact, evidence, safe recovery, prevention—keeps showing up across SRE, platform, cloud, data, and infrastructure roles.</p>
        <p><Link className="text-link" href="/practice/interview">Open interview practice -&gt;</Link></p>
      </header>
      <CareerOverview />
      <section className="primer-library" aria-labelledby="career-library-title">
        <div className="section-heading">
          <div>
            <p className="eyebrow">COMPLETE CAREER LIBRARY</p>
            <h2 id="career-library-title">Validated local primers, now readable in the manual.</h2>
            <p className="section-intro">These chapters are generated directly from the version-controlled <code>career/</code> source files. The website is a reader; Git remains the durable source, so a pull restores both the text and its local routes.</p>
          </div>
        </div>
        <div className="primer-library-grid">
          {careerPrimers.map((primer) => (
            <Link className="primer-library-card" href={`/career/${primer.slug}`} key={primer.slug}>
              <span>FIELD MANUAL</span>
              <strong>{primer.title}</strong>
              <small>Open the local chapter -&gt;</small>
            </Link>
          ))}
        </div>
      </section>
    </main>
  );
}
