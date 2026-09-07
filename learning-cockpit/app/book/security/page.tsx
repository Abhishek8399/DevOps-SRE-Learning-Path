import { VolumeBookIndex } from "../../foundation-volume";

export default function SecurityVolumePage() {
  return (
    <>
      <header className="volume-hero">
        <p className="eyebrow">VOLUME 08 / SECURITY ENGINEERING</p>
        <h1>Trace authority and exposure before adding another control.</h1>
        <p>Learn threat modeling, identity boundaries, software-supply-chain evidence, runtime controls, detection, containment, recovery, and residual-risk ownership.</p>
      </header>
      <section className="ubuntu-start">
        <div><span>FIRST SECURITY RULE</span><h2>A control is useful only when its protected promise and failure mode are explicit.</h2><p>Start with the asset, actor, authority, trust boundary, likely abuse path, existing evidence, and recovery owner.</p></div>
        <div className="ubuntu-preflight"><strong>READ-ONLY PREFLIGHT</strong><pre><code>{`uname -a
id
findmnt -no TARGET,OPTIONS /
ss -lntup 2>/dev/null || true`}</code></pre><p>These commands observe host identity, mount policy, and listeners. They change no security control.</p></div>
      </section>
      <VolumeBookIndex volumeId="08-security-engineering" eyebrow="VOLUME 08 / SECURITY ENGINEERING" heading="Engineer security as a verifiable system property." introduction="Read threat modeling before supply-chain and runtime controls; keep prevention, detection, containment, recovery, and accepted residual risk connected." />
    </>
  );
}
