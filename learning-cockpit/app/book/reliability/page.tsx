import { VolumeBookIndex } from "../../foundation-volume";

export default function ReliabilityVolumePage() {
  return (
    <>
      <header className="volume-hero">
        <p className="eyebrow">VOLUME 04 / RELIABILITY AND OPERATIONS</p>
        <h1>Turn uncertain signals into safe operational decisions.</h1>
        <p>
          Reliability engineering begins with evidence you can qualify. Learn how telemetry
          is produced, transformed, delayed, sampled, stored, queried, and translated into
          decisions without mistaking a dashboard for the system itself.
        </p>
      </header>

      <section className="ubuntu-start">
        <div>
          <span>FIRST RELIABILITY RULE</span>
          <h2>A signal is useful only when you understand its evidence boundary.</h2>
          <p>
            Name the user operation, trace the measurement path, check scope and freshness,
            separate observation from inference, and define the next safe experiment before
            changing a production system.
          </p>
        </div>
        <div className="ubuntu-preflight">
          <strong>READ-ONLY PREFLIGHT</strong>
          <pre><code>{`date --iso-8601=seconds
uptime
cat /proc/loadavg
cat /proc/meminfo | head`}</code></pre>
          <p>
            These commands expose local clock, load, and memory evidence. They do not prove
            application health, user success, production causality, or telemetry completeness.
          </p>
        </div>
      </section>

      <section className="environment-facts">
        <article><span>TESTED</span><strong>Ubuntu 24.04</strong><p>WSL 2 Ubuntu 24.04 is supported with its visibility limits stated.</p></article>
        <article><span>DEFAULT PRIVILEGE</span><strong>Non-root</strong><p>The local lab refuses root and limits mutation to an exact learner-owned lifecycle.</p></article>
        <article><span>DEFAULT NETWORK</span><strong>None</strong><p>The foundation lab installs nothing and makes no hosted telemetry or cloud call.</p></article>
        <article><span>MASTERY</span><strong>Evidence-gated</strong><p>Reading and guided verification never replace independent diagnosis and review.</p></article>
      </section>

      <VolumeBookIndex
        volumeId="04-reliability-operations"
        eyebrow="VOLUME 04 / RELIABILITY AND OPERATIONS"
        heading="Build trustworthy evidence before automating reliability decisions."
        introduction="Read in order. Start with signal production and loss boundaries, then connect observability to objectives, incidents, capacity, resilience, recovery, and operational design."
      />
    </>
  );
}
