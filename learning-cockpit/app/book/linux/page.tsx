import { BookIndex } from "../../foundation-volume";

export default function LinuxVolumePage() {
  return (
    <>
      <header className="volume-hero">
        <p className="eyebrow">VOLUME 01 / LINUX SYSTEMS</p>
        <h1>Understand the machine beneath every platform.</h1>
        <p>Docker, Kubernetes, CI runners, cloud VMs, and data platforms all inherit Linux mechanisms. Learn those mechanisms once, then recognize them everywhere.</p>
      </header>

      <section className="ubuntu-start">
        <div>
          <span>START HERE</span>
          <h2>Your Ubuntu workbench</h2>
          <p>Lessons prefer read-only inspection or bounded non-root resources on Ubuntu 24.04. Check commands before installing anything.</p>
        </div>
        <div className="ubuntu-preflight">
          <strong>READ-ONLY PREFLIGHT</strong>
          <pre><code>{`cat /etc/os-release
uname -a
printf 'PID 1: '; ps -p 1 -o comm=
for cmd in ps vmstat free findmnt namei ip ss getent curl openssl python3; do
  command -v "$cmd" >/dev/null || echo "missing=$cmd"
done`}</code></pre>
          <p>No output from the loop means every checked command is available. A missing command is a package decision, not permission to install automatically.</p>
        </div>
      </section>

      <section className="environment-facts">
        <article><span>TESTED</span><strong>Ubuntu 24.04</strong><p>WSL 2 supported unless a lesson explicitly needs a disposable VM.</p></article>
        <article><span>DEFAULT PRIVILEGE</span><strong>Non-root</strong><p>sudo is shown only as a separate reviewed step when the mechanism requires it.</p></article>
        <article><span>DEFAULT NETWORK</span><strong>None</strong><p>Package installation and network requests are labeled explicitly.</p></article>
        <article><span>MASTERY</span><strong>Evidence-gated</strong><p>Reading progress never changes the competency ledger.</p></article>
      </section>

      <BookIndex />
    </>
  );
}
