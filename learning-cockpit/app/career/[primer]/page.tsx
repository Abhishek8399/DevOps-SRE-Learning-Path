import { notFound } from "next/navigation";
import CareerPrimerArticle from "../../career-primer-article";
import { careerPrimers, findCareerPrimer } from "../../career-primer.server";

export function generateStaticParams() { return careerPrimers.map((primer) => ({ primer: primer.slug })); }

export default async function CareerPrimerPage({ params }: { params: Promise<{ primer: string }> }) {
  const { primer: slug } = await params;
  const primer = findCareerPrimer(slug);
  if (!primer) notFound();
  return <main className="cockpit-shell" id="main-content"><CareerPrimerArticle primer={primer} /></main>;
}
