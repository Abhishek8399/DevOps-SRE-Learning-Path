import Link from "next/link";
import { readerCatalog } from "./lessons/reader-catalog";
import NavigationLink from "./navigation-link";

const plannedVolumes = [
  ["00", "Start safely"],
  ["02", "Connectivity"],
  ["03", "Engineering & delivery"],
  ["04", "Reliability & operations"],
  ["05", "Infrastructure & platforms"],
  ["06", "Distributed systems"],
];

function NavigationLinks() {
  return (
    <nav aria-label="Book contents">
      <NavigationLink className="nav-home" href="/"><span>FIELD MANUAL</span><strong>Systems Reliability</strong></NavigationLink>
      <NavigationLink className="library-link" href="/book">Knowledge library</NavigationLink>
      <div className="nav-volume current-volume">
        <div><span>VOLUME 01</span><strong>Linux systems</strong></div>
        {readerCatalog.map((lesson) => (
          <NavigationLink href={lesson.route} key={lesson.canonicalId}><b>{lesson.number}</b> {lesson.title}</NavigationLink>
        ))}
      </div>
      <div className="planned-volumes">
        <span>KNOWLEDGE MAP</span>
        {plannedVolumes.map(([number, title]) => (
          <Link href="/book#knowledge-map" key={number}><b>{number}</b>{title}<small>PLANNED</small></Link>
        ))}
      </div>
      <NavigationLink className="practice-link" href="/search">Search the field manual <span>-&gt;</span></NavigationLink>
      <NavigationLink className="practice-link" href="/my-learning">My Learning <span>-&gt;</span></NavigationLink>
      <NavigationLink className="practice-link" href="/practice/storage">Storage practice lab <span>-&gt;</span></NavigationLink>
      <p className="nav-footnote">Available to read is not the same as verified mastery.</p>
    </nav>
  );
}

export default function BookNavigation() {
  return (
    <>
      <aside className="book-sidebar"><NavigationLinks /></aside>
      <details className="mobile-book-nav">
        <summary>Open book contents</summary>
        <NavigationLinks />
      </details>
    </>
  );
}
