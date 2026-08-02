import { VolumeBookIndex } from "../../foundation-volume";

export default function EngineeringVolumePage() {
  return (
    <>
      <header className="volume-hero">
        <p className="eyebrow">VOLUME 03 / ENGINEERING AND DELIVERY</p>
        <h1>Make every change inspectable, reproducible, and recoverable.</h1>
        <p>
          Production engineering starts before a pipeline runs. Learn how shells interpret
          commands, how Git records state, how programs fail, and how reviewed artifacts move
          through delivery systems without turning speed into uncontrolled risk.
        </p>
      </header>

      <section className="ubuntu-start">
        <div>
          <span>FIRST DELIVERY RULE</span>
          <h2>A fast change is useful only when you can explain and reverse it.</h2>
          <p>
            Identify the repository, inspect the exact state, understand what each command
            reads or mutates, preserve evidence, and define rollback before moving a change
            toward another person or environment.
          </p>
        </div>
        <div className="ubuntu-preflight">
          <strong>READ-ONLY PREFLIGHT</strong>
          <pre><code>{`pwd
id
git --version
bash --version | head -n 1
python3 --version`}</code></pre>
          <p>
            These commands identify the current workbench and available tools. They do not
            authorize installing packages, changing another repository, publishing code, or
            using credentials.
          </p>
        </div>
      </section>

      <section className="environment-facts">
        <article><span>TESTED</span><strong>Ubuntu 24.04</strong><p>WSL 2 Ubuntu 24.04 is supported for the local workbench lessons.</p></article>
        <article><span>DEFAULT PRIVILEGE</span><strong>Non-root</strong><p>Labs remain inside exact learner-owned paths and refuse unsafe cleanup boundaries.</p></article>
        <article><span>DEFAULT REMOTE</span><strong>None</strong><p>Core practice uses disposable local repositories and never needs a token or hosted service.</p></article>
        <article><span>MASTERY</span><strong>Evidence-gated</strong><p>A clean command or successful build is evidence for review, not proof of mastery.</p></article>
      </section>

      <VolumeBookIndex
        volumeId="03-engineering-delivery"
        eyebrow="VOLUME 03 / ENGINEERING AND DELIVERY"
        heading="Build the change path from a shell command to a trusted release."
        introduction="Read in order. Predict how each tool changes state, inspect the result, test failure paths, retain reviewable evidence, and prove rollback or cleanup."
      />
    </>
  );
}
