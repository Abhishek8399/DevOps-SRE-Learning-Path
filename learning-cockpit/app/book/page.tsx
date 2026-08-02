import Link from "next/link";
import { readerEntriesForVolume } from "../lessons/reader-catalog";

function lessonState(count: number): string {
  return `${count} ${count === 1 ? "LESSON" : "LESSONS"} AVAILABLE`;
}

const startLessonCount = readerEntriesForVolume("00-start-safely").length;
const linuxLessonCount = readerEntriesForVolume("01-linux-systems").length;

const volumes = [
  { number: "00", title: "Start safely", detail: "Systems thinking, evidence, cleanup, command risk, and a reliable learning workflow.", state: lessonState(startLessonCount), href: "/book/start" },
  { number: "01", title: "Linux systems", detail: "Storage, processes, CPU, memory, identity, permissions, and operating-system internals.", state: lessonState(linuxLessonCount), href: "/book/linux" },
  { number: "02", title: "Connectivity", detail: "Ethernet through TLS: routing, TCP, DNS, HTTP, proxies, load balancers, and PKI.", state: "PLANNED" },
  { number: "03", title: "Engineering and delivery", detail: "Git, Bash, Python, APIs, testing, artifacts, containers, CI/CD, and supply chain.", state: "PLANNED" },
  { number: "04", title: "Reliability and operations", detail: "Observability, SLOs, capacity, overload, incidents, toil, backup, and recovery.", state: "PLANNED" },
  { number: "05", title: "Infrastructure and platforms", detail: "Terraform, Ansible, Kubernetes internals, GitOps, golden paths, and platform SLOs.", state: "PLANNED" },
  { number: "06", title: "State and distributed systems", detail: "Databases, queues, streams, replication, consistency, consensus, and workflows.", state: "PLANNED" },
];

const tracks = [
  "AWS and EKS reliability",
  "Private cloud: KVM, OpenStack, Ceph, OVS/OVN",
  "Data and ML platforms",
  "Developer platforms and CI compute",
  "Security and DevSecOps",
  "Architecture, leadership, and FinOps",
  "AI-assisted operations and AI platforms",
];

export default function BookLibraryPage() {
  return (
    <>
      <header className="library-hero">
        <p className="eyebrow">THE COMPLETE LEARNING MAP</p>
        <h1>One field manual.<br /><em>Foundation to staff-level systems.</em></h1>
        <p>
          Begin with systems thinking and Ubuntu, then move outward into containers,
          Kubernetes, cloud, private infrastructure, data platforms, reliability,
          security, and architecture. Every chapter connects mechanism to production judgment.
        </p>
        <div className="library-actions">
          <Link href="/book/start">Begin with Volume 00</Link>
          <Link href="/my-learning">Resume and bookmarks</Link>
          <Link href="/search">Search lessons</Link>
        </div>
      </header>

      <section className="knowledge-map" id="knowledge-map">
        <div className="library-section-heading">
          <div><span>CORE CURRICULUM</span><h2>Build in dependency order</h2></div>
          <p>Planned means the place is reserved in the architecture. Content appears only after it is reviewed and locally validated.</p>
        </div>
        <div className="volume-grid">
          {volumes.map((volume) => {
            const content = <><div><span>{volume.number}</span><small>{volume.state}</small></div><strong>{volume.title}</strong><p>{volume.detail}</p></>;
            return volume.href
              ? <Link className="volume-card available" href={volume.href} key={volume.number}>{content}<b>Open volume -&gt;</b></Link>
              : <article className="volume-card" key={volume.number}>{content}</article>;
          })}
        </div>
      </section>

      <section className="track-map">
        <div className="library-section-heading"><div><span>SPECIALIST PATHS</span><h2>Deep tracks after the shared core</h2></div></div>
        <div className="track-list">{tracks.map((track) => <span key={track}>{track}</span>)}</div>
      </section>

      <aside className="library-principle">
        <strong>The promise of this book</strong>
        <p>Follow the system picture, check prerequisites, run the bounded Ubuntu lab, interpret the evidence, clean up, then see how the same mechanism behaves at production scale.</p>
      </aside>
    </>
  );
}
