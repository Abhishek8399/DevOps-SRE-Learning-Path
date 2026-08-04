import Link from "next/link";
import LibraryReadingDesk, { type LibraryLesson } from "../library-reading-desk";
import { readerCatalog, readerEntriesForVolume } from "../lessons/reader-catalog";
import { isLearningLessonId } from "../my-learning/learning-state";

type VolumeCover = Readonly<{
  number: string;
  title: string;
  subtitle: string;
  route?: string;
  count?: number;
  tone: string;
}>;

const availableCounts = {
  start: readerEntriesForVolume("00-start-safely").length,
  linux: readerEntriesForVolume("01-linux-systems").length,
  network: readerEntriesForVolume("02-connectivity").length,
  engineering: readerEntriesForVolume("03-engineering-delivery").length,
  reliability: readerEntriesForVolume("04-reliability-operations").length,
};

const volumes: VolumeCover[] = [
  { number: "00", title: "Foundations", subtitle: "Safe systems thinking", route: "/book/start", count: availableCounts.start, tone: "moss" },
  { number: "01", title: "Linux Systems", subtitle: "The machine beneath the platform", route: "/book/linux", count: availableCounts.linux, tone: "slate" },
  { number: "02", title: "Networking", subtitle: "Packets, names, trust and requests", route: "/book/connectivity", count: availableCounts.network, tone: "blue" },
  { number: "03", title: "Automation & Programming", subtitle: "Git, shells, Python and delivery", route: "/book/engineering", count: availableCounts.engineering, tone: "ochre" },
  { number: "04", title: "Site Reliability Engineering", subtitle: "Signals, objectives and incidents", route: "/book/reliability", count: availableCounts.reliability, tone: "rust" },
  { number: "05", title: "CI/CD & Release Engineering", subtitle: "From commit to safe production", tone: "indigo" },
  { number: "06", title: "Containers", subtitle: "Isolation, images and runtimes", tone: "blue" },
  { number: "07", title: "Kubernetes", subtitle: "Control loops and cluster operations", tone: "slate" },
  { number: "08", title: "Cloud Engineering", subtitle: "Reliable public-cloud systems", tone: "moss" },
  { number: "09", title: "Infrastructure as Code", subtitle: "Repeatable, reviewable change", tone: "ochre" },
  { number: "10", title: "Observability", subtitle: "Evidence across the request path", tone: "rust" },
  { number: "11", title: "Platform Engineering", subtitle: "Golden paths and paved roads", tone: "indigo" },
  { number: "12", title: "Security", subtitle: "Identity, policy and supply chain", tone: "rust" },
  { number: "13", title: "Distributed Systems", subtitle: "Time, state and partial failure", tone: "blue" },
  { number: "14", title: "Production Troubleshooting", subtitle: "Restore service with evidence", tone: "ochre" },
  { number: "15", title: "Architecture & Leadership", subtitle: "Trade-offs, influence and scale", tone: "moss" },
  { number: "16", title: "Interview Mastery", subtitle: "Explain and defend the system", tone: "indigo" },
];

const lessons: LibraryLesson[] = readerCatalog.map((lesson) => {
  if (!isLearningLessonId(lesson.stateId)) {
    throw new Error(`reader state identity is not trusted: ${lesson.stateId}`);
  }
  return {
    id: lesson.stateId,
    number: lesson.number,
    volumeNumber: lesson.volumeNumber,
    title: lesson.title,
    href: lesson.route,
  };
});

export default function BookLibraryPage() {
  return (
    <>
      <header className="field-library-hero">
        <div className="main-book-cover" aria-label="The Engineer's Field Manual cover">
          <span>RELIABILITY ATLAS</span>
          <div aria-hidden="true" className="cover-mark">
            <i /><i /><i /><i /><i />
          </div>
          <h1>The Engineer’s<br /><em>Field Manual</em></h1>
          <p>DevOps · SRE · Platform Engineering</p>
          <small>LOCAL FIELD EDITION / 2026</small>
        </div>
        <div className="library-hero-copy">
          <p className="eyebrow">THE COMPLETE SYSTEMS READING ROOM</p>
          <h2>Learn the mechanism.<br />Practise the judgment.</h2>
          <p>
            A local-first technical book for understanding production systems from the
            Linux process to the distributed platform. Read in dependency order, run
            bounded labs, interpret evidence, and return later without losing the map.
          </p>
          <div className="library-actions">
            <Link href="/book/start">Open Volume 00 <span aria-hidden="true">→</span></Link>
            <Link href="/search">Search the field manual</Link>
          </div>
          <dl className="library-edition-facts">
            <div><dt>Published</dt><dd>{lessons.length} lessons</dd></div>
            <div><dt>Runtime</dt><dd>Localhost</dd></div>
            <div><dt>Progress</dt><dd>Browser-local</dd></div>
          </dl>
        </div>
      </header>

      <LibraryReadingDesk lessons={lessons} />

      <section className="volume-collection" aria-labelledby="volume-collection-title">
        <div className="library-section-heading">
          <div><span>The collected field manuals</span><h2 id="volume-collection-title">Seventeen volumes. One dependency map.</h2></div>
          <p>Published covers open reviewed lessons. Reserved covers show the complete architecture without pretending unfinished content is ready.</p>
        </div>
        <div className="field-volume-grid">
          {volumes.map((volume) => {
            const cover = (
              <>
                <span className="cover-volume">VOL. {volume.number}</span>
                <div className="mini-cover-mark" aria-hidden="true"><i /><i /><i /></div>
                <h3>{volume.title}</h3>
                <p>{volume.subtitle}</p>
                <small>{volume.route ? `${volume.count} lessons available` : "Reserved in the curriculum"}</small>
                <b>{volume.route ? "Open volume →" : "Planned"}</b>
              </>
            );
            return volume.route
              ? <Link className={`field-volume-cover ${volume.tone}`} href={volume.route} key={volume.number}>{cover}</Link>
              : <article className={`field-volume-cover ${volume.tone} planned`} key={volume.number} aria-label={`${volume.title}, planned`}>{cover}</article>;
          })}
        </div>
      </section>

      <aside className="field-manual-principle">
        <span>Operator’s margin</span>
        <blockquote>“A command is not an answer. It is an experiment that must have a prediction, a boundary, and a recovery path.”</blockquote>
        <Link href="/my-learning">Open your reading desk →</Link>
      </aside>
    </>
  );
}
