import Link from "next/link";
import CareerPrimerLibrary from "../career-primer-library";
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
      <CareerPrimerLibrary primers={careerPrimers} />
    </main>
  );
}
