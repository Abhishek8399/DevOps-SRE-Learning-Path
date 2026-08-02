import Link from "next/link";
import { readerEntriesForVolume, type ReaderVolumeId } from "./lessons/reader-catalog";
import NavigationLink from "./navigation-link";

const availableVolumes: readonly Readonly<{
  id: ReaderVolumeId;
  number: string;
  title: string;
  route: string;
}>[] = [
  { id: "00-start-safely", number: "00", title: "Start safely", route: "/book/start" },
  { id: "01-linux-systems", number: "01", title: "Linux systems", route: "/book/linux" },
  { id: "02-connectivity", number: "02", title: "Connectivity", route: "/book/connectivity" },
  { id: "03-engineering-delivery", number: "03", title: "Engineering & delivery", route: "/book/engineering" },
  { id: "04-reliability-operations", number: "04", title: "Reliability & operations", route: "/book/reliability" },
];

const plannedVolumes = [
  ["05", "Infrastructure & platforms"],
  ["06", "Distributed systems"],
];

function NavigationLinks() {
  return (
    <nav aria-label="Book contents">
      <NavigationLink className="nav-home" href="/"><span>RELIABILITY ATLAS</span><strong>DevOps / SRE / Platform</strong></NavigationLink>
      <NavigationLink className="library-link" href="/book">Knowledge library</NavigationLink>
      {availableVolumes.map((volume) => (
        <div className="nav-volume current-volume" key={volume.id}>
          <div><span>VOLUME {volume.number}</span><strong>{volume.title}</strong></div>
          <NavigationLink href={volume.route}><b>{volume.number}</b> Volume index</NavigationLink>
          {readerEntriesForVolume(volume.id).map((lesson) => (
            <NavigationLink href={lesson.route} key={lesson.canonicalId}><b>{lesson.number}</b> {lesson.title}</NavigationLink>
          ))}
        </div>
      ))}
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
