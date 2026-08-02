import Link from "next/link";
import CopyCommand from "./copy-command";
import { CommandDecoderGuide, LessonAnswerGuide, LessonGlossary } from "./lesson-depth";
import { readerEntriesForVolume } from "./lessons/reader-catalog";

const linuxLessonCount = readerEntriesForVolume("01-linux-systems").length;

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
          <h1>Linux storage: blocks, inodes, and ENOSPC</h1>
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
        <a href="#storage-vocabulary">Vocabulary</a>
        <a href="#storage-signals">Signals</a>
        <a href="#storage-output-decoders">Output decoders</a>
        <a href="#storage-recovery">Recovery</a>
        <a href="#storage-ubuntu-lab">Ubuntu lab</a>
        <a href="#storage-isolated-lab">Failure lab</a>
        <a href="#storage-answers">Model answers</a>
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

      <LessonGlossary lessonId="storage" />

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

      <CommandDecoderGuide lessonId="storage" />

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
            <CopyCommand text="findmnt -T /var/lib/api/uploads" />
            <p>A path that looks like disk storage may actually be tmpfs, a volume, a container layer, or another mount.</p>
          </article>
          <article>
            <div><span>READ-ONLY</span><strong>Compare independent limits</strong></div>
            <code>df -hT /var/lib/api/uploads</code>
            <CopyCommand text="df -hT /var/lib/api/uploads" />
            <code>df -i /var/lib/api/uploads</code>
            <CopyCommand text="df -i /var/lib/api/uploads" />
            <p>Free blocks do not compensate for zero free inodes. Both checks target the same failed path.</p>
          </article>
          <article>
            <div><span>READ-ONLY / POTENTIALLY EXPENSIVE</span><strong>Locate file-count pressure</strong></div>
            <code>du --inodes -x -d 1 /var/lib/api</code>
            <CopyCommand text="du --inodes -x -d 1 /var/lib/api" />
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

      <div className="chapter-block ubuntu-lab-block" id="storage-ubuntu-lab">
        <div className="chapter-copy">
          <p className="chapter-number">04 / UBUNTU-FIRST GUIDED LAB</p>
          <h3>Watch object count consume inodes without filling or damaging your host.</h3>
          <p>
            Run this directly in a normal Ubuntu 24.04 shell. The experiment creates
            100 empty files inside one private temporary directory. Empty files use
            almost no data blocks, but each filesystem object still needs an inode.
          </p>
        </div>

        <div className="lab-requirements" aria-label="Storage lab environment and safety">
          <article><span>ENVIRONMENT</span><strong>Ubuntu 24.04 or WSL 2 Ubuntu</strong></article>
          <article><span>TIME</span><strong>8-12 minutes</strong></article>
          <article><span>PACKAGES</span><strong>coreutils and findutils</strong></article>
          <article><span>PRIVILEGE</span><strong>Normal user; no sudo</strong></article>
          <article><span>CHANGE SCOPE</span><strong>101 tiny files in one private /tmp directory</strong></article>
        </div>

        <ol className="lab-steps">
          <li>
            <span>READ-ONLY / PREFLIGHT</span><strong>Confirm the commands and your non-root identity.</strong>
            <pre><code>{`command -v df
command -v find
command -v mktemp
command -v seq
if test "$(id -u)" -eq 0; then
  echo 'STOP: open a normal non-root Ubuntu shell'
else
  echo 'non_root=true'
fi`}</code></pre>
            <p>Stop if a command is missing or the result says to use a non-root shell.</p>
          </li>
          <li>
            <span>MUTATING / PRIVATE TEMP DIRECTORY</span><strong>Create the bounded lab and record the baseline.</strong>
            <pre><code>{`unset LAB_DIR
if test "$(id -u)" -eq 0; then
  echo 'STOP: open a normal non-root Ubuntu shell'
else
  LAB_DIR="$(mktemp -d --tmpdir=/tmp sre-inodes.XXXXXXXX)"
  printf 'sre-inode-lab-v1\n' > "$LAB_DIR/.sre-lab-sentinel"
  printf 'lab_path=%s\n' "$LAB_DIR"
  df -hT "$LAB_DIR"
  df -i "$LAB_DIR"
fi`}</code></pre>
            <p>The exact path selects the filesystem that backs this lab. Keep this shell open so <code>LAB_DIR</code> remains available.</p>
          </li>
          <li>
            <span>MUTATING / 100 EMPTY LAB FILES</span><strong>Create objects, then compare object and inode counts.</strong>
            <pre><code>{`LAB_REAL="$(realpath -e -- "\${LAB_DIR:-}" 2>/dev/null || true)"
case "$(basename -- "$LAB_REAL" 2>/dev/null)" in
  sre-inodes.*)
    if test "$(id -u)" -ne 0 \\
      && test -n "$LAB_REAL" \\
      && test "$(dirname -- "$LAB_REAL")" = /tmp \\
      && test "$(stat -c '%u' "$LAB_REAL")" = "$(id -u)" \\
      && test "$(cat "$LAB_REAL/.sre-lab-sentinel" 2>/dev/null)" = 'sre-inode-lab-v1'; then
      LAB_DIR="$LAB_REAL"
      for number in $(seq -w 1 100); do
        : > "$LAB_DIR/object-$number"
      done
      find "$LAB_DIR" -xdev -maxdepth 1 -type f -name 'object-*' | wc -l
      df -i "$LAB_DIR"
      du -sh "$LAB_DIR"
    else
      echo 'STOP: non-root lab boundary, owner, or sentinel not proven'
    fi
    ;;
  *) echo 'STOP: path is outside /tmp/sre-inodes.*' ;;
esac`}</code></pre>
            <p>Expected: 100 matching objects and very little block usage. Filesystem-wide inode use should rise, although concurrent system activity can also change the total.</p>
          </li>
          <li>
            <span>READ-ONLY / CONNECT THE MODEL</span><strong>Inspect one name, inode record, and file size.</strong>
            <pre><code>{`find "$LAB_DIR" -maxdepth 1 -type f -name 'object-*' -printf '%f\n' | head
stat -c 'name=%n inode=%i bytes=%s mode=%A owner=%U:%G' \
  "$LAB_DIR/object-001"`}</code></pre>
            <p>The filename points to a distinct inode number even though the file contains zero bytes.</p>
          </li>
          <li>
            <span>DESTRUCTIVE / SENTINEL-GUARDED EXACT POPULATION</span><strong>Prove path and ownership, remove only generated objects, then verify cleanup.</strong>
            <pre><code>{`LAB_REAL="$(realpath -e -- "\${LAB_DIR:-}" 2>/dev/null || true)"
case "$(basename -- "$LAB_REAL" 2>/dev/null)" in
  sre-inodes.*)
    if test -n "$LAB_REAL" \\
      && test "$(dirname -- "$LAB_REAL")" = /tmp \\
      && test "$(stat -c '%u' "$LAB_REAL")" = "$(id -u)" \\
      && test "$(cat "$LAB_REAL/.sre-lab-sentinel" 2>/dev/null)" = 'sre-inode-lab-v1'; then
      LAB_DIR="$LAB_REAL"
      find "$LAB_DIR" -xdev -maxdepth 1 -type f -name 'object-*' -delete
      UNEXPECTED="$(find "$LAB_DIR" -xdev -mindepth 1 -maxdepth 1 ! -name '.sre-lab-sentinel' -print -quit)"
      if test -n "$UNEXPECTED"; then
        printf 'refusing cleanup: unexpected entry remains: %s\n' "$UNEXPECTED"
      else
        rm -- "$LAB_DIR/.sre-lab-sentinel"
        if rmdir -- "$LAB_DIR"; then
          echo 'cleanup_verified=true'
          unset LAB_DIR LAB_REAL UNEXPECTED
        else
          printf 'sre-inode-lab-v1\n' > "$LAB_DIR/.sre-lab-sentinel"
          echo 'cleanup incomplete: sentinel restored for a safe retry'
        fi
      fi
    else
      echo 'refusing cleanup: expected an owned direct child of /tmp with the lesson sentinel'
    fi
    ;;
  *) echo 'refusing cleanup: path is outside /tmp/sre-inodes.*' ;;
esac`}</code></pre>
            <p>The resolved path, direct <code>/tmp</code> parent, current owner, and exact lesson sentinel must all match. Unexpected entries block final cleanup, and a failed <code>rmdir</code> restores the sentinel so cleanup can be retried safely.</p>
          </li>
        </ol>

        <aside className="wisdom-note">
          <strong>What this proves</strong>
          <span>Object creation consumes inode capacity independently of file-content size. It does not reproduce ENOSPC, and that is intentional on your host.</span>
        </aside>
      </div>

      <div className="chapter-block lab-block" id="storage-isolated-lab">
        <div className="chapter-copy">
          <p className="chapter-number">05 / OPTIONAL ISOLATED FAILURE LAB</p>
          <h3>When you are ready, recover a real ENOSPC fixture inside Docker.</h3>
          <p>
            We use Docker here because deliberately exhausting host inode capacity is
            unsafe. This deletion policy applies only to container <code>devops-sre-p1-enospc</code>:
            files matching <code>/var/lib/api/uploads/.runtime/cache/objects/*.part</code>
            are disposable. <code>.retained-data</code> must survive.
          </p>
          <p>
            <strong>Hard boundary:</strong> start from the repository root in Ubuntu and use the controller below.
            Run every absolute <code>/var/lib/api/uploads</code>
            command only after the container-boundary check succeeds inside that shell.
          </p>
        </div>

        <ol className="lab-steps">
          <li>
            <span>HOST / MUTATING SETUP AND INTERACTIVE EXEC</span><strong>Build, verify, then enter the isolated fixture as its unprivileged user.</strong>
            <pre><code>{`cd phase-01-foundations/lesson-01-linux-storage-enospc
bash lab.sh setup
bash lab.sh check
bash lab.sh shell`}</code></pre>
            <p>
              <code>setup</code> builds only from the pinned local base image and creates the named fixture. If the pinned image is missing, the script prints
              the one explicit networked <code>docker pull</code> command and stops. <code>check</code> proves the full image, entrypoint, user, mount,
              namespace, privilege, network, and resource envelope before it verifies the incident. The shell is refused unless that complete check passes.
              If setup reports an existing container, use <code>bash lab.sh status</code>. For the specifically recognized legacy v1 lesson fixture only,
              run <code>bash lab.sh cleanup</code>, repeat setup and check, then enter the shell. Any other mismatch is a stop condition.
            </p>
          </li>
          <li>
            <span>CONTAINER / READ-ONLY BOUNDARY CHECK</span><strong>Prove this is the disposable ENOSPC fixture before touching its files.</strong>
            <pre><code>{`test "$(id -u)" -eq 65534 \\
  && test -f /run/lab-ready \\
  && test -f /var/lib/api/uploads/.retained-data \\
  && test "$(df -T /var/lib/api/uploads | awk 'NR == 2 { print $2 }')" = tmpfs \\
  && echo 'container_boundary_verified=true' \\
  || { echo 'STOP: disposable container boundary not proven'; exit 1; }`}</code></pre>
            <p>All four facts must be true: unprivileged fixture UID, readiness marker, retained-data marker, and a <code>tmpfs</code>-backed target. If any check fails, stop.</p>
          </li>
          <li>
            <span>CONTAINER / READ-ONLY</span><strong>Count and preview the approved population.</strong>
            <pre><code>{`find /var/lib/api/uploads/.runtime/cache/objects \\
  -xdev -maxdepth 1 -type f -name '*.part' | wc -l

find /var/lib/api/uploads/.runtime/cache/objects \\
  -xdev -maxdepth 1 -type f -name '*.part' | head -n 5`}</code></pre>
            <p>Expected: 499 matching fragments. Stop if the count or path differs.</p>
          </li>
          <li>
            <span>CONTAINER / DESTRUCTIVE / DISPOSABLE LAB FILES ONLY</span><strong>Re-prove the fixture, then delete using the same reviewed filters.</strong>
            <pre><code>{`test "$(id -u)" -eq 65534 \\
  && test -f /run/lab-ready \\
  && test -f /var/lib/api/uploads/.retained-data \\
  && test "$(df -T /var/lib/api/uploads | awk 'NR == 2 { print $2 }')" = tmpfs \\
  || { echo 'STOP: disposable container boundary not proven'; exit 1; }

find /var/lib/api/uploads/.runtime/cache/objects \\
  -xdev -maxdepth 1 -type f -name '*.part' -delete`}</code></pre>
            <p>No parent directory, wildcard-only <code>rm</code>, or unrelated path is authorized.</p>
          </li>
          <li>
            <span>CONTAINER / READ-ONLY</span><strong>Verify inode recovery and retained data.</strong>
            <pre><code>{`df -i /var/lib/api/uploads
test -f /var/lib/api/uploads/.retained-data \\
  && echo 'retained_data_present=true'`}</code></pre>
          </li>
          <li>
            <span>CONTAINER / DESTRUCTIVE / EXACT TEST FILE</span><strong>Re-prove the fixture, retry the failed write, then remove exactly that test file.</strong>
            <pre><code>{`test "$(id -u)" -eq 65534 \\
  && test -f /run/lab-ready \\
  && test -f /var/lib/api/uploads/.retained-data \\
  && test "$(df -T /var/lib/api/uploads | awk 'NR == 2 { print $2 }')" = tmpfs \\
  || { echo 'STOP: disposable container boundary not proven'; exit 1; }

touch /var/lib/api/uploads/7f9c.tmp
test -f /var/lib/api/uploads/7f9c.tmp \\
  && echo 'upload_path_write_recovered=true'
rm -- /var/lib/api/uploads/7f9c.tmp`}</code></pre>
            <p>In production, replace <code>touch</code> with a controlled request through the real API.</p>
          </li>
          <li>
            <span>HOST / DESTRUCTIVE / OWNED LAB CONTAINER</span><strong>Leave the fixture and remove only the fully verified teaching container.</strong>
            <pre><code>{`exit
bash lab.sh cleanup`}</code></pre>
            <p>
              <code>lab.sh cleanup</code> verifies the exact name, lesson label, approved image generation, expected user for that generation,
              isolated network, and read-only root filesystem before removal. The current v2 fixture must be unprivileged; the narrowly supported
              legacy v1 fixture used root and is accepted for removal only so it can be replaced safely. Success reports <code>cleanup_verified=true</code>.
            </p>
          </li>
        </ol>

        <aside className="wisdom-note">
          <strong>Operator sentence</strong>
          <span>Diagnose the resource, authorize the population, bound the change, then verify the user journey.</span>
        </aside>
      </div>
      <LessonAnswerGuide lessonId="storage" />

      <nav className="lesson-pagination" aria-label="Lesson 01 navigation">
        <Link href="/book/linux">&lt;- {linuxLessonCount}-lesson index</Link>
        <Link href="/book/linux/processes-signals-systemd">Next lesson: processes -&gt;</Link>
      </nav>

    </section>
  );
}
