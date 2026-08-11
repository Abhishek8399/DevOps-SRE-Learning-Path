import Link from "next/link";
import type { Metadata } from "next";
import { readerEntriesForVolume } from "./lessons/reader-catalog";
import styles from "./home.module.css";

export const metadata: Metadata = {
  title: "Reliability Atlas",
  description: "The DevOps, SRE & Platform Engineering Field Manual. A local-first, evidence-driven path from foundations to production judgment.",
};

function availableLessons(count: number): string {
  return `${count} ${count === 1 ? "lesson" : "lessons"} available`;
}

const stages = [
  {
    number: "01",
    title: "Start Safely",
    detail: "Systems thinking, evidence boundaries, command risk, cleanup, and controlled troubleshooting.",
    state: availableLessons(readerEntriesForVolume("00-start-safely").length),
    href: "/book/start",
  },
  {
    number: "02",
    title: "Linux",
    detail: "Filesystems, processes, boot, systemd, identity, CPU, memory, and the operating system beneath every platform.",
    state: availableLessons(readerEntriesForVolume("01-linux-systems").length),
    href: "/book/linux",
  },
  {
    number: "03",
    title: "Networking",
    detail: "Packets to requests: routing, DNS, TCP, TLS, HTTP, proxies, load balancers, and failure localization.",
    state: availableLessons(readerEntriesForVolume("02-connectivity").length),
    href: "/book/connectivity",
  },
  {
    number: "04",
    title: "Engineering & Delivery",
    detail: "Git, Bash, Python, APIs, testing, artifacts, containers, CI/CD, rollback, and software supply chains.",
    state: availableLessons(readerEntriesForVolume("03-engineering-delivery").length),
    href: "/book/engineering",
  },
  {
    number: "05",
    title: "Observability & SRE",
    detail: "Signals, SLIs, SLOs, alert quality, incidents, capacity, overload, toil, resilience, and recovery.",
    state: availableLessons(readerEntriesForVolume("04-reliability-operations").length),
    href: "/book/reliability",
  },
  {
    number: "06",
    title: "IaC & Kubernetes",
    detail: "Terraform, configuration management, Kubernetes internals, GitOps, upgrades, and platform operations.",
  },
  {
    number: "07",
    title: "Data & Distributed Systems",
    detail: "Databases, caches, queues, streams, consistency, replication, consensus, and data-platform reliability.",
  },
  {
    number: "08",
    title: "Security & Platform Design",
    detail: "Least privilege, secrets, policy, tenancy, golden paths, self-service, cost, governance, and architecture tradeoffs.",
  },
  {
    number: "09",
    title: "Capstones & Interviews",
    detail: "Cross-system incidents, production design reviews, operational narratives, interview drills, and reviewed evidence.",
  },
] as const;

export default function Home() {
  return (
    <main className={styles.page} id="main-content">
      <header className={styles.masthead}>
        <a className={styles.brand} href="#atlas-top" aria-label="Reliability Atlas home">
          <span className={styles.brandMark} aria-hidden="true">RA</span>
          <span>
            <strong>Reliability Atlas</strong>
            <small>Field manual and learning map</small>
          </span>
        </a>
        <nav className={styles.navigation} aria-label="Primary navigation">
          <a href="#journey">Learning journey</a>
          <Link href="/book">Library</Link>
          <Link href="/career">Career map</Link>
          <Link href="/search">Search</Link>
          <Link href="/my-learning">My learning</Link>
        </nav>
        <p className={styles.localStatus}><span aria-hidden="true" /> Local-first and private</p>
      </header>

      <section className={styles.hero} id="atlas-top" aria-labelledby="atlas-title">
        <div className={styles.heroCopy}>
          <p className={styles.eyebrow}>LOCAL LEARNING SYSTEM / FOUNDATION TO EXPERT</p>
          <h1 id="atlas-title">Reliability <em>Atlas</em></h1>
          <p className={styles.subtitle}>The DevOps, SRE &amp; Platform Engineering Field Manual</p>
          <p className={styles.introduction}>
            Learn the system in dependency order. Trace the real request path, decode the
            evidence, practise inside bounded local labs, and separate reading progress from
            demonstrated engineering judgment.
          </p>
          <div className={styles.actions} aria-label="Start learning">
            <Link className={styles.primaryAction} href="/book/start">
              Begin at Start Safely <span aria-hidden="true">-&gt;</span>
            </Link>
            <Link className={styles.secondaryAction} href="/book">Open current lessons</Link>
            <Link className={styles.secondaryAction} href="/search">Search the manual</Link>
          </div>
          <dl className={styles.heroFacts}>
            <div><dt>Runtime</dt><dd>Localhost</dd></div>
            <div><dt>Learning record</dt><dd>Browser-local</dd></div>
            <div><dt>Mastery rule</dt><dd>Evidence before claims</dd></div>
          </dl>
        </div>
        <aside className={styles.compass} aria-labelledby="compass-title">
          <p className={styles.cardLabel}>OPERATOR COMPASS</p>
          <h2 id="compass-title">Use the manual like an engineer, not a checklist.</h2>
          <ol>
            <li><span>01</span><div><strong>Map</strong><small>Name the user operation and every boundary it crosses.</small></div></li>
            <li><span>02</span><div><strong>Predict</strong><small>Say what should be true before running a command.</small></div></li>
            <li><span>03</span><div><strong>Prove</strong><small>Collect evidence and state what it cannot establish.</small></div></li>
            <li><span>04</span><div><strong>Move safely</strong><small>Bound the change, rollback, and verification path.</small></div></li>
          </ol>
          <p className={styles.compassRule}><strong>Reading is progress.</strong> Reviewed operational evidence is competency.</p>
        </aside>
      </section>

      <section className={styles.journeySection} id="journey" aria-labelledby="journey-title">
        <header className={styles.sectionHeader}>
          <div>
            <p className={styles.eyebrow}>DEPENDENCY-ORDERED JOURNEY</p>
            <h2 id="journey-title">One route through the systems that production depends on.</h2>
          </div>
          <p>
            Start with the five available stages. Planned stages reserve the curriculum order;
            they have no lesson route and do not imply that content or competency exists yet.
          </p>
        </header>
        <div className={styles.legend} aria-label="Journey status legend">
          <span><i className={styles.availableKey} aria-hidden="true" /> Available to study</span>
          <span><i className={styles.plannedKey} aria-hidden="true" /> Planned, not published</span>
        </div>
        <ol className={styles.journeyList}>
          {stages.map((stage) => (
            <li className={"href" in stage ? styles.availableStage : styles.plannedStage} key={stage.number}>
              <span className={styles.stageMarker} aria-hidden="true">{stage.number}</span>
              {"href" in stage ? (
                <Link className={styles.stageCard} href={stage.href}>
                  <span className={styles.stageTopline}><strong>AVAILABLE</strong><small>{stage.state}</small></span>
                  <h3>{stage.title}</h3>
                  <p>{stage.detail}</p>
                  <span className={styles.openStage}>Open stage <b aria-hidden="true">-&gt;</b></span>
                </Link>
              ) : (
                <article className={styles.stageCard} aria-label={`${stage.title}, planned`}>
                  <span className={styles.stageTopline}><strong>PLANNED</strong><small>No route published</small></span>
                  <h3>{stage.title}</h3>
                  <p>{stage.detail}</p>
                  <span className={styles.plannedNote}>Reserved for reviewed, locally validated content.</span>
                </article>
              )}
            </li>
          ))}
        </ol>
      </section>

      <section className={styles.operatingModel} aria-labelledby="operating-model-title">
        <header className={styles.sectionHeader}>
          <div>
            <p className={styles.eyebrow}>HOW THIS ATLAS WORKS</p>
            <h2 id="operating-model-title">Durable knowledge without false confidence.</h2>
          </div>
        </header>
        <div className={styles.principleGrid}>
          <article>
            <span>01 / LOCAL</span>
            <h3>Learn without a cloud account</h3>
            <p>The reader, source lessons, and bounded labs live in this repository. Current study paths work on localhost; networked infrastructure appears only when a later lesson genuinely requires it.</p>
          </article>
          <article>
            <span>02 / DURABLE</span>
            <h3>Keep the manual in Git</h3>
            <p>Lessons, diagrams, commands, assessments, and safety contracts remain reviewable source. Pull the repository later and the learning architecture still explains itself.</p>
          </article>
          <article>
            <span>03 / EVIDENCE</span>
            <h3>Never confuse reading with mastery</h3>
            <p>Bookmarks and finished-reading markers are private conveniences. Competency requires observable reasoning, safe execution, cleanup, and reviewer-accepted evidence.</p>
          </article>
        </div>
      </section>

      <section className={styles.entryPanel} aria-labelledby="entry-title">
        <div>
          <p className={styles.eyebrow}>CURRENT ENTRY POINT</p>
          <h2 id="entry-title">Begin with safe evidence, then earn the next layer.</h2>
          <p>Open Volume 00 for the operating method, browse every published lesson, or search by symptom, command, term, curriculum ID, or canonical lesson ID.</p>
        </div>
        <div className={styles.entryActions}>
          <Link href="/book/start">Start Volume 00 <span aria-hidden="true">-&gt;</span></Link>
          <Link href="/book">Browse the library</Link>
          <Link href="/search">Search all current lessons</Link>
          <Link href="/practice/interview">Practice interview scenarios</Link>
        </div>
      </section>

      <footer className={styles.footer}>
        <strong>Reliability Atlas</strong>
        <span>Local-first learning. Production-grade judgment. Evidence before mastery.</span>
      </footer>
    </main>
  );
}
