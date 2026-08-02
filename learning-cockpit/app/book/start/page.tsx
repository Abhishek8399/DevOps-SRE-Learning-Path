import { VolumeBookIndex } from "../../foundation-volume";

export default function StartSafelyVolumePage() {
  return (
    <>
      <header className="volume-hero">
        <p className="eyebrow">VOLUME 00 / START SAFELY</p>
        <h1>Learn to see a system before you touch it.</h1>
        <p>
          Build the operator habits that make every later Linux, networking,
          Kubernetes, and reliability lesson safer: map state, boundaries,
          dependencies, queues, and failure domains before choosing a command.
        </p>
      </header>

      <section className="ubuntu-start">
        <div>
          <span>FIRST PRINCIPLE</span>
          <h2>A symptom is a starting point, not a diagnosis.</h2>
          <p>
            Follow the request or state path, find the first abnormal boundary,
            and separate observed evidence from assumptions. That habit prevents
            fast but wrong production changes.
          </p>
        </div>
        <div className="ubuntu-preflight">
          <strong>SAFE WORKBENCH CHECK</strong>
          <pre><code>{`cat /etc/os-release
python3 --version
id
pwd`}</code></pre>
          <p>These commands only identify your environment. The guided lesson lab is bounded, non-root, offline, and includes cleanup proof.</p>
        </div>
      </section>

      <section className="environment-facts">
        <article><span>STARTING LEVEL</span><strong>No prior curriculum</strong><p>Technical terms are introduced before they are used.</p></article>
        <article><span>DEFAULT PRIVILEGE</span><strong>Non-root</strong><p>The first lab writes only to its validated lesson-specific paths under <code>/tmp</code>.</p></article>
        <article><span>DEFAULT NETWORK</span><strong>None</strong><p>The queue model uses only the Python standard library.</p></article>
        <article><span>MASTERY</span><strong>Evidence-gated</strong><p>Reading progress never changes the competency ledger.</p></article>
      </section>

      <VolumeBookIndex
        volumeId="00-start-safely"
        eyebrow="VOLUME 00 / START SAFELY"
        heading="The operator mental model everything else depends on."
        introduction="Study the map, run the bounded model, interpret the measurements, then explain the changed constraint in your own words."
      />
    </>
  );
}
