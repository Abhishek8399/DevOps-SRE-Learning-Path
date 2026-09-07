import { VolumeBookIndex } from "../../foundation-volume";

export default function AiVolumePage() {
  return (
    <>
      <header className="volume-hero">
        <p className="eyebrow">VOLUME 07 / AI ENGINEERING</p>
        <h1>Validate the outcome before trusting intelligent automation.</h1>
        <p>
          Learn how model uncertainty, context, retrieval, tools, evaluation, security,
          observability, capacity, cost, rollout, and human authority shape reliable AI systems.
        </p>
      </header>
      <section className="ubuntu-start">
        <div>
          <span>FIRST AI RULE</span>
          <h2>A fluent answer is not evidence that the answer is correct.</h2>
          <p>
            Bind every AI-assisted operation to an explicit task, trusted evidence,
            measured evaluation, bounded authority, and a recoverable fallback.
          </p>
        </div>
        <div className="ubuntu-preflight">
          <strong>READ-ONLY PREFLIGHT</strong>
          <pre><code>{`uname -a
id
python3 --version
free -h`}</code></pre>
          <p>These commands inventory the local host. They install no model, package, or service.</p>
        </div>
      </section>
      <VolumeBookIndex
        volumeId="07-ai-engineering"
        eyebrow="VOLUME 07 / AI ENGINEERING"
        heading="Treat AI as an uncertain component inside an engineered control system."
        introduction="Read in order: validated assistance first, then operational intelligence, secure tool use, production serving, and governed recovery."
      />
    </>
  );
}
