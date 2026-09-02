import { VolumeBookIndex } from "../../foundation-volume";

export default function InfrastructureVolumePage() {
  return (
    <>
      <header className="volume-hero">
        <p className="eyebrow">VOLUME 05 / INFRASTRUCTURE AND PLATFORMS</p>
        <h1>Turn infrastructure changes into reviewable, recoverable systems.</h1>
        <p>
          Learn how desired configuration, state, remote reality, automation controllers,
          and Kubernetes reconciliation interact before you authorize a change.
        </p>
      </header>
      <section className="ubuntu-start">
        <div>
          <span>FIRST INFRASTRUCTURE RULE</span>
          <h2>Reconcile configuration, state, and reality before changing any of them.</h2>
          <p>
            A plan is a proposal, state is a binding record, and a controller is an actor.
            Name ownership and rollback boundaries before execution.
          </p>
        </div>
        <div className="ubuntu-preflight">
          <strong>READ-ONLY PREFLIGHT</strong>
          <pre><code>{`uname -a
id
command -v terraform || true
command -v kubectl || true`}</code></pre>
          <p>These commands inventory the local host. They install nothing and prove no provider or cluster behavior.</p>
        </div>
      </section>
      <VolumeBookIndex
        volumeId="05-infrastructure-platforms"
        eyebrow="VOLUME 05 / INFRASTRUCTURE AND PLATFORMS"
        heading="Build controlled change systems before operating shared platforms."
        introduction="Read in order: infrastructure-as-code foundations, plan semantics, state recovery, configuration management, then Kubernetes reconciliation."
      />
    </>
  );
}
