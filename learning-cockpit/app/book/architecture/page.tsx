import { VolumeBookIndex } from "../../foundation-volume";

export default function ArchitectureVolumePage() {
  return (
    <>
      <header className="volume-hero">
        <p className="eyebrow">VOLUME 10 / ARCHITECTURE &amp; LEADERSHIP</p>
        <h1>Make trade-offs explicit, evidence-bound, and operable.</h1>
        <p>Connect system design, migration strategy, technical writing, organizational leadership, and interview communication into one senior-engineering practice.</p>
      </header>
      <VolumeBookIndex volumeId="10-architecture-leadership" eyebrow="VOLUME 10 / ARCHITECTURE & LEADERSHIP" heading="Design systems people can operate and decisions people can revisit." introduction="Start with system boundaries and quality attributes, then progress through migration governance, operational writing, leadership, and evidence-backed interview narratives." />
    </>
  );
}
