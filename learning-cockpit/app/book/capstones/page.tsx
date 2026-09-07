import { VolumeBookIndex } from "../../foundation-volume";

export default function CapstonesVolumePage() {
  return (
    <>
      <header className="volume-hero">
        <p className="eyebrow">VOLUME 11 / CAPSTONES</p>
        <h1>Integrate mechanisms into systems you can explain, test, and recover.</h1>
        <p>Use these projects to connect service reliability, platform engineering, distributed data, private cloud, and secured AI operations without confusing a local exercise with production proof.</p>
      </header>
      <VolumeBookIndex volumeId="11-capstones" eyebrow="VOLUME 11 / CAPSTONES" heading="Build the whole path, then defend every boundary." introduction="Each capstone combines several earlier volumes. Follow the guided path, preserve exact evidence, inject only bounded faults, prove recovery and cleanup, then attempt the answer-isolated transfer with an independent reviewer." />
    </>
  );
}
