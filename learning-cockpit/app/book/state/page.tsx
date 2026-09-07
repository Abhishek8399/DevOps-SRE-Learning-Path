import { VolumeBookIndex } from "../../foundation-volume";

export default function StateVolumePage() {
  return (
    <>
      <header className="volume-hero">
        <p className="eyebrow">VOLUME 06 / STATE AND DISTRIBUTED SYSTEMS</p>
        <h1>Follow the transaction before trusting the database dashboard.</h1>
        <p>
          Learn how data contracts, query execution, concurrency, durability, replication,
          recovery, and partial failure shape the user-visible result.
        </p>
      </header>
      <section className="ubuntu-start">
        <div>
          <span>FIRST STATE RULE</span>
          <h2>Availability without correctness is still an outage.</h2>
          <p>
            Bind every database symptom to one user operation, transaction outcome,
            authoritative state, and recoverable point before changing the system.
          </p>
        </div>
        <div className="ubuntu-preflight">
          <strong>READ-ONLY PREFLIGHT</strong>
          <pre><code>{`uname -a
id
command -v docker || true
docker version 2>/dev/null || true`}</code></pre>
          <p>These commands inventory the local host and Docker client. They create no database or container.</p>
        </div>
      </section>
      <VolumeBookIndex
        volumeId="06-state-distributed-systems"
        eyebrow="VOLUME 06 / STATE AND DISTRIBUTED SYSTEMS"
        heading="Understand state, concurrency, and recovery before operating distributed data."
        introduction="Read in order: relational contracts and PostgreSQL internals, then caches, distributed systems, queues, workflows, pipelines, and platform data services."
      />
    </>
  );
}
