import CareerOverview from "./career-overview";
import FoundationVolume, { BookIndex } from "./foundation-volume";
import StorageChapter from "./storage-chapter";
import InteractivePractice from "./interactive-practice";

export default function Home() {
  return (
    <main className="cockpit-shell">
      <header className="topbar">
        <a className="brand" href="#top">
          <span className="brand-mark">A</span>
          <span>
            <strong>Abhishek&apos;s Learning Cockpit</strong>
            <small>DevOps · SRE · Platform Engineering</small>
          </span>
        </a>
        <nav className="book-links" aria-label="Learning book navigation">
          <a href="#map">Roadmap</a>
          <a href="#book-index">Book</a>
          <a href="#practice">Practice</a>
        </nav>
        <div className="status-pill"><span /> Local-only · no cloud cost</div>
      </header>

      <section className="hero" id="top">
        <div className="hero-copy">
          <p className="eyebrow">PHASE 01 · LINUX FOUNDATIONS</p>
          <h1>See the signal.<br /><em>Understand the system.</em><br />Make the safe move.</h1>
          <p className="hero-text">Picture the system, predict what happens, operate the lab, then explain it like the engineer responsible for production.</p>
          <a className="primary-button" href="#lesson">Continue today&apos;s incident <span>→</span></a>
        </div>
        <aside className="mission-card">
          <p className="card-label">TODAY&apos;S MISSION</p>
          <h2>Recover an API from inode exhaustion</h2>
          <div className="progress-track"><span /></div>
          <div className="mission-meta"><span><strong>L1</strong> Current evidence</span><span><strong>30m</strong> Focus block</span></div>
          <div className="mission-rule"><span>Remember</span><p>ENOSPC is the alarm, not the diagnosis.</p></div>
        </aside>
      </section>
      <CareerOverview />
      <section className="lesson-panel" id="lesson">
        <div className="section-heading">
          <div>
            <p className="eyebrow">FAILURE ZOOM</p>
            <h2>Why 8.4 MB free can still mean “no space”</h2>
          </div>
          <span className="live-badge">● LAB RUNNING</span>
        </div>
        <div className="failure-flow">
          <article className="flow-node">
            <span>1</span><small>APPLICATION</small><strong>Create upload</strong><code>7f9c.tmp</code>
          </article>
          <div className="flow-arrow">→</div>
          <article className="flow-node">
            <span>2</span><small>LINUX VFS</small><strong>Resolve path</strong><code>/var/lib/api/uploads</code>
          </article>
          <div className="flow-arrow">→</div>
          <article className="flow-node">
            <span>3</span><small>TMPFS /VAR</small><strong>Allocate resources</strong>
            <b className="ok">Blocks 52% free</b><b className="bad">Inodes 0 free</b>
          </article>
          <div className="flow-arrow danger">-&gt;</div>
          <article className="flow-node failure">
            <span>4</span><small>KERNEL</small><strong>ENOSPC</strong>
            <code>No space left on device</code>
          </article>
        </div>
        <div className="decision-strip">
          <div><span>WHEN YOU SEE</span><strong>ENOSPC + free blocks</strong></div><b>-&gt;</b>
          <div><span>THINK</span><strong>Check independent limits</strong></div><b>-&gt;</b>
          <div><span>PROVE WITH</span><strong>findmnt + df -hT + df -i</strong></div>
        </div>
      </section>
      <BookIndex />
      <StorageChapter />
      <FoundationVolume />
      <InteractivePractice />
    </main>
  );
}
