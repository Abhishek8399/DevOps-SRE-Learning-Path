import Link from "next/link";
import { readerEntriesForVolume, type ReaderVolumeId } from "./lessons/reader-catalog";
import NavigationLink from "./navigation-link";
import NavigationVolume from "./navigation-volume";
import ShellToggle from "./shell-toggle";

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
  { id: "05-infrastructure-platforms", number: "05", title: "Infrastructure & platforms", route: "/book/infrastructure" },
];

const plannedVolumes = [
  ["06", "Containers"],
  ["07", "Kubernetes"],
  ["08", "Cloud engineering"],
  ["09", "Infrastructure as code"],
  ["10", "Observability"],
  ["11", "Platform engineering"],
  ["12", "Security"],
  ["13", "Distributed systems"],
  ["14", "Production troubleshooting"],
  ["15", "Architecture & leadership"],
  ["16", "Interview mastery"],
];

function NavigationLinks() {
  return (
    <nav aria-label="Book contents">
      <div className="nav-identity">
        <NavigationLink className="nav-home" href="/"><span aria-hidden="true">RA</span><strong>Reliability Atlas</strong><small>The Engineer&apos;s Field Manual</small></NavigationLink>
        <ShellToggle action="close-navigation" className="rail-close" label="Close" />
      </div>
      <div className="nav-utilities">
        <NavigationLink href="/book">Library</NavigationLink>
        <NavigationLink href="/drafts">Extended chapters</NavigationLink>
        <NavigationLink href="/career">Career map</NavigationLink>
        <NavigationLink href="/search">Search</NavigationLink>
        <NavigationLink href="/my-learning">My learning</NavigationLink>
      </div>
      {availableVolumes.map((volume) => (
        <NavigationVolume
          key={volume.id}
          lessons={readerEntriesForVolume(volume.id)}
          number={volume.number}
          route={volume.route}
          title={volume.title}
        />
      ))}
      <details className="planned-volumes">
        <summary><span>Future volumes</span><b aria-hidden="true">+</b></summary>
        <div>{plannedVolumes.map(([number, title]) => (
          <Link href="/book#volume-collection-title" key={number}><b>{number}</b>{title}<small>PLANNED</small></Link>
        ))}</div>
      </details>
      <NavigationLink className="practice-link" href="/practice/storage">Open storage practice <span aria-hidden="true">-&gt;</span></NavigationLink>
      <NavigationLink className="practice-link" href="/practice/interview">Open interview practice <span aria-hidden="true">-&gt;</span></NavigationLink>
      <p className="nav-footnote">Available to read is not the same as verified mastery.</p>
    </nav>
  );
}

export default function BookNavigation() {
  return (
    <>
      <aside className="book-sidebar" id="book-navigation"><NavigationLinks /></aside>
      <ShellToggle action="close-navigation" className="navigation-backdrop" label="Close book navigation" />
    </>
  );
}
