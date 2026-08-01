import Link from "next/link";
import CopyCommand from "./copy-command";
import { foundationLessons, type FoundationLesson } from "./lessons/foundation-lessons";
import { CommandDecoderGuide, LessonAnswerGuide, LessonGlossary } from "./lesson-depth";

const indexLessons = [
  {
    number: "01",
    title: "Filesystems, blocks, inodes, and ENOSPC",
    detail: "Map the path, distinguish limits, remediate safely.",
    href: "/book/linux/storage",
    state: "PRACTICAL GATE",
  },
  ...foundationLessons.map((lesson) => ({
    number: lesson.number,
    title: lesson.title,
    detail: lesson.subtitle,
    href: `/book/linux/${lesson.id}`,
    state: "READY TO STUDY",
  })),
];

export function BookIndex() {
  return (
      <section className="book-index" id="book-index">
        <div className="section-heading light">
          <div>
            <p className="eyebrow">VOLUME 01 / LINUX SYSTEMS</p>
            <h2>Five lessons that everything else will stand on.</h2>
            <p className="section-intro">
              Read in order. A lesson being available means it is ready to learn;
              it does not mean the competency gate has been passed.
            </p>
          </div>
          <span className="volume-count">5 LESSONS</span>
        </div>
        <div className="lesson-shelf">
          {indexLessons.map((lesson) => (
            <Link href={lesson.href} className="shelf-card" key={lesson.number}>
              <div><span>{lesson.number}</span><small>{lesson.state}</small></div>
              <strong>{lesson.title}</strong>
              <p>{lesson.detail}</p>
              <b>Open lesson -&gt;</b>
            </Link>
          ))}
        </div>
        <aside className="study-protocol">
          <strong>How to use this volume</strong>
          <span>Read the picture first.</span><b>-&gt;</b>
          <span>Translate each signal.</span><b>-&gt;</b>
          <span>Run the bounded lab.</span><b>-&gt;</b>
          <span>Explain the incident path.</span>
        </aside>
      </section>

  );
}

export function FoundationLessonArticle({ lesson }: { lesson: FoundationLesson }) {
  const lessonIndex = foundationLessons.findIndex((item) => item.id === lesson.id);
  return (
    <article className="foundation-lesson routed-lesson" id={lesson.id}>
          <header className="lesson-heading">
            <div className="lesson-number">{lesson.number}</div>
            <div>
              <p className="eyebrow">LINUX FOUNDATION / READY TO STUDY</p>
              <h1>{lesson.title}</h1>
              <p>{lesson.subtitle}</p>
            </div>
          </header>
          <nav className="chapter-nav lesson-jump-nav" aria-label={`${lesson.title} sections`}>
            <a href={`#${lesson.id}-mental-model`}>Mental model</a>
            <a href={`#${lesson.id}-vocabulary`}>Vocabulary</a>
            <a href={`#${lesson.id}-mechanisms`}>Internals</a>
            <a href={`#${lesson.id}-incident`}>Incident</a>
            <a href={`#${lesson.id}-commands`}>Evidence</a>
            <a href={`#${lesson.id}-output-decoders`}>Output decoders</a>
            <a href={`#${lesson.id}-lab`}>Ubuntu lab</a>
            <a href={`#${lesson.id}-answers`}>Model answers</a>
          </nav>

          <section className="lesson-split" id={`${lesson.id}-mental-model`}>
            <div className="lesson-prose">
              <p className="lesson-label">MENTAL MODEL</p>
              <h3>Where your mind should go</h3>
              <p>{lesson.mentalModel}</p>
              <aside><strong>Memory sentence</strong><span>{lesson.memoryRule}</span></aside>
            </div>
            <div className="ascii-diagram">
              <span>SYSTEM PICTURE</span>
              <pre>{lesson.diagram}</pre>
            </div>
          </section>

          <LessonGlossary lessonId={lesson.id} />

          <section className="lesson-section" id={`${lesson.id}-mechanisms`}>
            <div className="lesson-section-title">
              <p className="lesson-label">TECHNICAL REALITY</p>
              <h3>Mechanisms you must be able to explain</h3>
            </div>
            <div className="mechanism-grid">
              {lesson.mechanisms.map((mechanism) => (
                <article key={mechanism.term}>
                  <strong>{mechanism.term}</strong>
                  <p>{mechanism.explanation}</p>
                </article>
              ))}
            </div>
          </section>

          <section className="incident-walkthrough" id={`${lesson.id}-incident`}>
            <div className="incident-title"><span>PRODUCTION SCENARIO</span><strong>{lesson.incident.signal}</strong></div>
            <div><small>FIRST THOUGHT</small><p>{lesson.incident.firstThought}</p></div>
            <div><small>SAFE PATH</small><p>{lesson.incident.safePath}</p></div>
            <div className="incident-trap"><small>COMMON TRAP</small><p>{lesson.incident.trap}</p></div>
          </section>

          <section className="lesson-section" id={`${lesson.id}-commands`}>
            <div className="lesson-section-title">
              <p className="lesson-label">COMMANDS AS EVIDENCE</p>
              <h3>Know what each command proves and what it cannot prove</h3>
            </div>
            <div className="evidence-commands">
              {lesson.commands.map((item) => (
                <article key={item.command}>
                  <div className="command-line">
                    <span>{item.classification}</span>
                    <code>{item.command}</code>
                    <CopyCommand text={item.command} />
                  </div>
                  <div><strong>PROVES</strong><p>{item.proves}</p></div>
                  <div><strong>DOES NOT PROVE</strong><p>{item.doesNotProve}</p></div>
                </article>
              ))}
            </div>
          </section>

          <CommandDecoderGuide lessonId={lesson.id} />

          <section className="guided-lab" id={`${lesson.id}-lab`}>
            <div className="lesson-section-title">
              <p className="lesson-label">GUIDED LOCAL LAB</p>
              <h3>Turn the picture into observable evidence</h3>
              <p><strong>Scope:</strong> {lesson.lab.scope}</p>
            </div>
            <div className="lab-requirements" aria-label="Lab environment and safety">
              <article><span>ENVIRONMENT</span><strong>{lesson.lab.requirements.environment}</strong></article>
              <article><span>TIME</span><strong>{lesson.lab.requirements.time}</strong></article>
              <article><span>PACKAGES</span><strong>{lesson.lab.requirements.packages}</strong></article>
              <article><span>PRIVILEGE</span><strong>{lesson.lab.requirements.privilege}</strong></article>
              <article><span>CHANGE SCOPE</span><strong>{lesson.lab.requirements.risk}</strong></article>
            </div>
            <ol>
              {lesson.lab.steps.map((step) => (
                <li key={step.action}>
                  <span>{step.label}</span>
                  <strong>{step.action}</strong>
                  <CopyCommand text={step.command} />
                  <pre><code>{step.command}</code></pre>
                  <p>{step.meaning}</p>
                </li>
              ))}
            </ol>
            <div className="lab-success">
              <div><strong>SUCCESS EVIDENCE</strong>{lesson.lab.success.map((item) => <span key={item}>{item}</span>)}</div>
              <div><strong>CLEANUP / RECOVERY</strong><p>{lesson.lab.cleanup}</p></div>
            </div>
          </section>

          <LessonAnswerGuide lessonId={lesson.id} />

          <nav className="lesson-pagination" aria-label={`Lesson ${lesson.number} navigation`}>
            <Link href={lessonIndex === 0 ? "/book/linux/storage" : `/book/linux/${foundationLessons[lessonIndex - 1].id}`}>
              &lt;- Previous lesson
            </Link>
            <Link href="/book/linux">Five-lesson index</Link>
            {lessonIndex < foundationLessons.length - 1
              ? <Link href={`/book/linux/${foundationLessons[lessonIndex + 1].id}`}>Next lesson -&gt;</Link>
              : <Link href="/practice/storage">Practise this volume -&gt;</Link>}
          </nav>
    </article>
  );
}

export default function FoundationVolume() {
  return (
    <>
      {foundationLessons.map((lesson) => <FoundationLessonArticle lesson={lesson} key={lesson.id} />)}
    </>
  );
}
