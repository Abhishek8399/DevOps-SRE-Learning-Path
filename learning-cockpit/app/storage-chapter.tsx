const comparisons = [
  {
    resource: "Data blocks",
    purpose: "Hold file content",
    command: "df -hT <path>",
    exhausted: "Large writes and new content fail",
  },
  {
    resource: "Inodes",
    purpose: "Hold filesystem-object records",
    command: "df -i <path>",
    exhausted: "New files and directories fail",
  },
];

export default function StorageChapter() {
  return (
    <section className="book-chapter" id="storage-chapter">
      <header className="chapter-heading">
        <div>
          <p className="eyebrow">BOOK / CHAPTER 01</p>
          <h2>Linux storage: blocks, inodes, and ENOSPC</h2>
          <p>
            Abhishek, when you see <code>ENOSPC</code>, read it as: Linux could not
            allocate a required storage resource. Do not translate it immediately
            into &quot;the disk is full.&quot;
          </p>
        </div>
        <span className="chapter-state">FOUNDATION IN PROGRESS</span>
      </header>

      <nav className="chapter-nav" aria-label="Chapter sections">
        <a href="#storage-model">Mental model</a>
        <a href="#storage-signals">Signals</a>
        <a href="#storage-recovery">Recovery</a>
        <a href="#storage-lab">Lab</a>
      </nav>

      <div className="chapter-block" id="storage-model">
        <div className="chapter-copy">
          <p className="chapter-number">01 / MENTAL MODEL</p>
          <h3>A file needs an identity and somewhere to hold its content.</h3>
          <p>
            The filename lives in a directory entry. That name points to an inode.
            The inode stores filesystem metadata and points toward the file&apos;s data.
            The content consumes data blocks.
          </p>
          <aside className="wisdom-note">
            <strong>Memory sentence</strong>
            <span>Blocks answer &quot;how much data?&quot; Inodes answer &quot;how many objects?&quot;</span>
          </aside>
        </div>
        <div className="file-model" aria-label="Filename to inode to data block relationship">
          <article><small>DIRECTORY ENTRY</small><strong>report.log</strong><span>human-readable name</span></article>
          <b>-&gt;</b>
          <article><small>INODE 8412</small><strong>metadata</strong><span>type, owner, mode, times, block pointers</span></article>
          <b>-&gt;</b>
          <article><small>DATA BLOCKS</small><strong>file content</strong><span>the bytes inside report.log</span></article>
        </div>
      </div>

      <div className="chapter-block" id="storage-signals">
        <div className="chapter-copy">
          <p className="chapter-number">02 / READ THE SIGNALS</p>
          <h3>Two capacity meters, one error message.</h3>
          <p>
            Both resources belong to the filesystem behind the exact failing path.
            That is why every command below receives the path instead of inspecting
            an unrelated filesystem by accident.
          </p>
        </div>
        <div className="comparison-table">
          <div className="comparison-head"><span>RESOURCE</span><span>JOB</span><span>PROVE WITH</span><span>WHEN EMPTY</span></div>
          {comparisons.map((item) => (
            <div className="comparison-row" key={item.resource}>
              <strong>{item.resource}</strong><span>{item.purpose}</span><code>{item.command}</code><span>{item.exhausted}</span>
            </div>
          ))}
        </div>
        <div className="signal-rule">
          <code>df -hT /var/lib/api/uploads</code><span>shows blocks plus filesystem type</span>
          <code>df -i /var/lib/api/uploads</code><span>shows inode capacity</span>
        </div>
      </div>

      <div className="chapter-block" id="storage-recovery">
        <div className="chapter-copy">
          <p className="chapter-number">03 / SAFE RECOVERY</p>
          <h3>You do not clear inodes. You remove approved filesystem objects.</h3>
          <p>
            Inode exhaustion tells you the failed resource. It does not identify the
            producer, decide retention, or grant deletion permission. First locate the
            high-file-count population; then prove that the exact population is disposable.
          </p>
        </div>

        <div className="recovery-flow" aria-label="Safe inode exhaustion recovery flow">
          <article><span>1</span><strong>Map</strong><small>Find the filesystem behind the failed path.</small></article>
          <b>-&gt;</b>
          <article><span>2</span><strong>Prove</strong><small>Compare blocks, inodes, quota, and runtime limits.</small></article>
          <b>-&gt;</b>
          <article><span>3</span><strong>Locate</strong><small>Find the directory producing excessive objects.</small></article>
          <b>-&gt;</b>
          <article><span>4</span><strong>Authorize</strong><small>Confirm owner, age, retention, and recovery.</small></article>
          <b>-&gt;</b>
          <article><span>5</span><strong>Recover</strong><small>Change only the reviewed population.</small></article>
          <b>-&gt;</b>
          <article><span>6</span><strong>Verify</strong><small>Check headroom and the real user operation.</small></article>
        </div>

        <div className="command-lessons">
          <article>
            <div><span>READ-ONLY</span><strong>Map the exact path</strong></div>
            <code>findmnt -T /var/lib/api/uploads</code>
            <p>A path that looks like disk storage may actually be tmpfs, a volume, a container layer, or another mount.</p>
          </article>
          <article>
            <div><span>READ-ONLY</span><strong>Compare independent limits</strong></div>
            <code>df -hT /var/lib/api/uploads</code>
            <code>df -i /var/lib/api/uploads</code>
            <p>Free blocks do not compensate for zero free inodes. Both checks target the same failed path.</p>
          </article>
          <article>
            <div><span>READ-ONLY / POTENTIALLY EXPENSIVE</span><strong>Locate file-count pressure</strong></div>
            <code>du --inodes -x -d 1 /var/lib/api</code>
            <p>Start narrow. A recursive inode scan can add I/O pressure to an already unhealthy filesystem.</p>
          </article>
          <article>
            <div><span>DECISION GATE</span><strong>Prove deletion safety</strong></div>
            <p>Directory name is not policy. Confirm the producer, business purpose, age, retention, backup, exact match rule, and approver.</p>
          </article>
        </div>

        <aside className="trap-note">
          <strong>Common production trap</strong>
          <p>Deleting the largest file usually frees one inode. Truncating it frees blocks but keeps its inode. For inode exhaustion, investigate excessive object count.</p>
        </aside>
      </div>

      <div className="chapter-block lab-block" id="storage-lab">
        <div className="chapter-copy">
          <p className="chapter-number">04 / CURRENT PRACTICAL MISSION</p>
          <h3>Recover the disposable lab without touching retained data.</h3>
          <p>
            This deletion policy applies only to container <code>devops-sre-p1-enospc</code>:
            files matching <code>/var/lib/api/uploads/.runtime/cache/objects/*.part</code>
            are disposable. <code>.retained-data</code> must survive.
          </p>
        </div>

        <ol className="lab-steps">
          <li>
            <span>READ-ONLY</span><strong>Count and preview the approved population.</strong>
            <pre><code>{`find /var/lib/api/uploads/.runtime/cache/objects \\
  -xdev -maxdepth 1 -type f -name '*.part' | wc -l

find /var/lib/api/uploads/.runtime/cache/objects \\
  -xdev -maxdepth 1 -type f -name '*.part' | head -n 5`}</code></pre>
            <p>Expected: 499 matching fragments. Stop if the count or path differs.</p>
          </li>
          <li>
            <span>DESTRUCTIVE / DISPOSABLE LAB FILES ONLY</span><strong>Delete using the same reviewed filters.</strong>
            <pre><code>{`find /var/lib/api/uploads/.runtime/cache/objects \\
  -xdev -maxdepth 1 -type f -name '*.part' -delete`}</code></pre>
            <p>No parent directory, wildcard-only <code>rm</code>, or unrelated path is authorized.</p>
          </li>
          <li>
            <span>READ-ONLY</span><strong>Verify inode recovery and retained data.</strong>
            <pre><code>{`df -i /var/lib/api/uploads
test -f /var/lib/api/uploads/.retained-data \\
  && echo 'retained_data_present=true'`}</code></pre>
          </li>
          <li>
            <span>MUTATING / EXACT TEST FILE</span><strong>Retry the operation that previously failed.</strong>
            <pre><code>{`touch /var/lib/api/uploads/7f9c.tmp
test -f /var/lib/api/uploads/7f9c.tmp \\
  && echo 'upload_path_write_recovered=true'
rm -f /var/lib/api/uploads/7f9c.tmp`}</code></pre>
            <p>In production, replace <code>touch</code> with a controlled request through the real API.</p>
          </li>
        </ol>

        <aside className="wisdom-note">
          <strong>Operator sentence</strong>
          <span>Diagnose the resource, authorize the population, bound the change, then verify the user journey.</span>
        </aside>
      </div>
      <nav className="lesson-pagination" aria-label="Lesson 01 navigation">
        <a href="#book-index">&lt;- Five-lesson index</a>
        <a href="#processes-signals-systemd">Next lesson: processes -&gt;</a>
      </nav>

    </section>
  );
}
