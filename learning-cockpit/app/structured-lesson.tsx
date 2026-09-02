import Link from "next/link";
import CopyCommand from "./copy-command";
import EditorialCodeBlock from "./editorial-code-block";
import {
  adjacentReaderEntries,
  findReaderEntry,
  readerEntriesForVolume,
  resolveReaderPrerequisites,
  type ReaderPrerequisiteContext,
} from "./lessons/reader-catalog";
import {
  headingAnchor,
  type AnsweredAssessment,
  type IndependentAssessment,
  type MarkdownBlock,
  type MarkdownInline,
  type StructuredLessonBundle,
  type StructuredLessonMetadata,
} from "./lessons/structured-lesson-parser";
import styles from "./structured-lesson.module.css";

function InlineContent({ content }: { content: readonly MarkdownInline[] }) {
  return content.map((inline, index) => {
    const key = `${inline.kind}-${index}-${inline.text.slice(0, 16)}`;
    if (inline.kind === "strong") return <strong key={key}>{inline.text}</strong>;
    if (inline.kind === "code") return <code key={key}>{inline.text}</code>;
    if (inline.kind === "link" && inline.href) {
      return inline.href.startsWith("/") || inline.href.startsWith("#")
        ? <Link href={inline.href} key={key}>{inline.text}</Link>
        : <a href={inline.href} key={key} rel="noreferrer" target="_blank">{inline.text}</a>;
    }
    return <span key={key}>{inline.text}</span>;
  });
}

function MarkdownBlocks({ blocks }: { blocks: readonly MarkdownBlock[] }) {
  return (
    <div className={styles.markdown}>
      {blocks.map((block, index) => {
        const key = `${block.kind}-${index}`;
        if (block.kind === "heading") {
          const text = block.content.map((inline) => inline.text).join("");
          const id = headingAnchor(text);
          return block.level === 3
            ? <h3 id={id} key={key}><InlineContent content={block.content} /></h3>
            : <h4 id={id} key={key}><InlineContent content={block.content} /></h4>;
        }
        if (block.kind === "paragraph") {
          return <p key={key}><InlineContent content={block.content} /></p>;
        }
        if (block.kind === "quote") {
          return <blockquote key={key}><InlineContent content={block.content} /></blockquote>;
        }
        if (block.kind === "unordered-list" || block.kind === "ordered-list") {
          const List = block.kind === "ordered-list" ? "ol" : "ul";
          return (
            <List key={key}>
              {block.items.map((item, itemIndex) => (
                <li key={`${key}-${itemIndex}`}><InlineContent content={item} /></li>
              ))}
            </List>
          );
        }
        if (block.kind === "code") {
          return <EditorialCodeBlock diagram={block.language === "text"} key={key} language={block.language} value={block.value} />;
        }
        return (
          <div aria-label="Scrollable technical table" className={styles.tableWrap} key={key} role="region" tabIndex={0}>
            <table>
              <thead><tr>{block.headers.map((header, headerIndex) => (
                <th key={`${key}-h-${headerIndex}`} scope="col"><InlineContent content={header} /></th>
              ))}</tr></thead>
              <tbody>{block.rows.map((row, rowIndex) => (
                <tr key={`${key}-r-${rowIndex}`}>{row.map((cell, cellIndex) => (
                  <td data-label={block.headers[cellIndex]?.map((item) => item.text).join("")} key={`${key}-${rowIndex}-${cellIndex}`}>
                    <InlineContent content={cell} />
                  </td>
                ))}</tr>
              ))}</tbody>
            </table>
          </div>
        );
      })}
    </div>
  );
}

function DiagramCards({ bundle }: { bundle: StructuredLessonBundle }) {
  return (
    <div className={styles.diagramCards} aria-label="Diagram evidence boundaries">
      {bundle.lesson.metadata.diagrams.map((diagram) => (
        <article key={diagram.id}>
          <div className={styles.cardTopline}><span>{diagram.id}</span><b>{diagram.direction}</b></div>
          <h3>{diagram.title}</h3>
          <div className={styles.boundaryFlow}>
            {diagram.boundaries.map((boundary, index) => (
              <span key={boundary}>{boundary}{index < diagram.boundaries.length - 1 ? "  ->" : ""}</span>
            ))}
          </div>
          <p>{diagram.textAlternative}</p>
          <dl><dt>Evidence points</dt><dd>{diagram.evidencePoints.join(" / ")}</dd></dl>
        </article>
      ))}
    </div>
  );
}

function IncidentCards({ bundle }: { bundle: StructuredLessonBundle }) {
  return (
    <div className={styles.incidentCards}>
      {bundle.lesson.metadata.incidents.map((incident) => (
        <article key={incident.id}>
          <span>{incident.id} / PRODUCTION INCIDENT</span>
          <h3>{incident.signal}</h3>
          <dl>
            <div><dt>First thought</dt><dd>{incident.firstThought}</dd></div>
            <div><dt>Safe evidence path</dt><dd>{incident.safePath}</dd></div>
            <div className={styles.trap}><dt>Common trap</dt><dd>{incident.trap}</dd></div>
          </dl>
        </article>
      ))}
    </div>
  );
}

function CommandCards({ bundle }: { bundle: StructuredLessonBundle }) {
  return (
    <div className={styles.commandCards}>
      {bundle.lesson.metadata.commands.map((command, index) => (
        <article key={command.id}>
          <header>
            <span>COMMAND {String(index + 1).padStart(2, "0")} / {command.risk.toUpperCase()}</span>
            <h3>{command.question}</h3>
          </header>
          <div className={styles.commandLine}>
            <code>{command.command}</code><CopyCommand text={command.command} />
          </div>
          <p className={styles.runFrom}><strong>Run from:</strong> {command.runFrom}</p>
          <div className={styles.branches}>
            {command.expectedBranches.map((branch) => (
              <div key={branch.when}>
                <strong>WHEN YOU SEE</strong><p>{branch.when}</p>
                <strong>IT MEANS</strong><p>{branch.meaning}</p>
                <strong>PROVE NEXT</strong><p>{branch.nextEvidence}</p>
              </div>
            ))}
          </div>
          <div className={styles.proofBoundary}>
            <div><strong>PROVES</strong><p>{command.proves}</p></div>
            <div><strong>DOES NOT PROVE</strong><p>{command.doesNotProve}</p></div>
          </div>
        </article>
      ))}
    </div>
  );
}

function LabCards({ bundle }: { bundle: StructuredLessonBundle }) {
  return (
    <div className={styles.labCards}>
      {bundle.lesson.metadata.labs.map((lab) => (
        <article key={lab.id}>
          <header><span>{lab.id} / {lab.mode.toUpperCase()}</span><h3>{lab.title}</h3></header>
          <dl className={styles.labFacts}>
            <div><dt>Environment</dt><dd>{lab.environment}</dd></div>
            <div><dt>Time</dt><dd>{lab.timeMinutes} minutes</dd></div>
            <div><dt>Privilege</dt><dd>{lab.privilege}</dd></div>
            <div><dt>Network</dt><dd>{lab.network}</dd></div>
          </dl>
          <div className={styles.safetyColumns}>
            <div><strong>CHANGES</strong><ul>{lab.changes.map((item) => <li key={item}>{item}</li>)}</ul></div>
            <div><strong>ABORT CONDITIONS</strong><ul>{lab.abortConditions.map((item) => <li key={item}>{item}</li>)}</ul></div>
          </div>
          <div className={styles.cleanup}><strong>RECOVERY</strong><p>{lab.recovery}</p><strong>CLEANUP PROOF</strong><p>{lab.cleanupProof}</p></div>
        </article>
      ))}
    </div>
  );
}

export function StructuredLessonContext({ metadata }: { metadata: StructuredLessonMetadata }) {
  return <aside aria-label="Chapter operating context" className={styles.chapterContext}>
    <section><strong>TESTED WORKBENCHES</strong><ul>{metadata.testedEnvironments.map((environment) => <li key={`${environment.platform}-${environment.version}`}><b>{environment.platform} {environment.version}</b><span>{environment.support}{environment.notes ? ` / ${environment.notes}` : ""}</span></li>)}</ul></section>
    <section><strong>WHO THIS CHAPTER HELPS</strong><ul>{metadata.targetRoles.map((role) => <li key={role}>{role}</li>)}</ul></section>
    <section><strong>PRODUCTION SIGNALS TO RECOGNIZE</strong><ul>{metadata.productionSignals.map((signal) => <li key={signal}>{signal}</li>)}</ul></section>
    <footer><span>DOMAIN {metadata.curriculumIds.join(" / ")}</span><span>REVIEWED {metadata.lastReviewed}</span><span>RECHECK AFTER {metadata.reviewAfter}</span></footer>
  </aside>;
}

function AnsweredCard({ assessment }: { assessment: AnsweredAssessment }) {
  return (
    <details className={styles.answerCard}>
      <summary><div><span>{assessment.id} / {assessment.type.toUpperCase()} / {assessment.difficulty.toUpperCase()}</span><h3>{assessment.prompt}</h3></div><b>Reveal the complete teaching answer</b></summary>
      <section className={styles.directAnswer}><strong>THE DIRECT ANSWER</strong><p>{assessment.directAnswer}</p></section>
      <section><strong>BUILD THE FOUNDATION</strong><p>{assessment.foundation}</p></section>
      <section><strong>REASONING, STEP BY STEP</strong><ol>{assessment.reasoningSteps.map((step) => <li key={step}>{step}</li>)}</ol></section>
      <section className={styles.seniorAnswer}><strong>HOW A SENIOR SRE WOULD ANSWER</strong><p>{assessment.seniorAnswer}</p></section>
      <div className={styles.weakAnswer}><section><strong>COMMON WEAK ANSWER</strong><p>{assessment.weakAnswer}</p></section><section><strong>WHY IT IS WEAK</strong><p>{assessment.whyWeak}</p></section></div>
      <section><strong>EVIDENCE BOUNDARIES</strong><div className={styles.assessmentEvidence}>{assessment.evidence.map((item) => <article key={item.signal}><h4>{item.signal}</h4><p><b>Proves:</b> {item.proves}</p><p><b>Does not prove:</b> {item.doesNotProve}</p></article>)}</div></section>
      <section><strong>ANSWERED FOLLOW-UPS</strong><dl className={styles.followUps}>{assessment.followUps.map((item) => <div key={item.prompt}><dt>{item.prompt}</dt><dd>{item.answer}</dd></div>)}</dl></section>
      <section className={styles.rubric}><strong>REVIEW RUBRIC / {assessment.maximumScore} POINTS</strong>{assessment.rubric.map((row) => <div key={row.criterion}><b>{row.criterion} / {row.points}</b><p>{row.observableEvidence}</p></div>)}</section>
    </details>
  );
}

function IndependentCard({ assessment }: { assessment: IndependentAssessment }) {
  return (
    <article className={styles.independentCard}>
      <header><span>{assessment.id} / ANSWER-ISOLATED / {assessment.difficulty.toUpperCase()}</span><h3>{assessment.prompt}</h3></header>
      <p className={styles.noAnswer}>No model answer is stored or rendered. Submit your own sanitized evidence for reviewer-only evaluation.</p>
      <div className={styles.safetyColumns}>
        <section><strong>DELIVERABLES</strong><ol>{assessment.deliverables.map((item) => <li key={item}>{item}</li>)}</ol></section>
        <section><strong>EVIDENCE REQUIREMENTS</strong><ul>{assessment.evidenceRequirements.map((item) => <li key={item}>{item}</li>)}</ul></section>
      </div>
      <section className={styles.rubric}><strong>OBSERVABLE RUBRIC / {assessment.maximumScore} POINTS</strong>{assessment.rubric.map((row) => <div key={row.criterion}><b>{row.criterion} / {row.points}</b><p>{row.observableEvidence}</p></div>)}</section>
    </article>
  );
}

function ReferenceCards({ bundle }: { bundle: StructuredLessonBundle }) {
  return <div className={styles.references}>{bundle.references.map((reference) => <article key={reference.id}><span>{reference.id} / {reference.sourceType.toUpperCase()}</span><h3><a href={reference.url} rel="noreferrer" target="_blank">{reference.title}</a></h3><p>{reference.organization} / {reference.versionOrDate}</p><p>{reference.relevance}</p><small>Reviewed {reference.lastReviewed}; review after {reference.reviewAfter}</small></article>)}</div>;
}

export function StructuredOperationalSupplement({ section, bundle }: { section: string; bundle: StructuredLessonBundle }) {
  if (section === "Architecture map") return <DiagramCards bundle={bundle} />;
  if (section === "Failure zoom") return <IncidentCards bundle={bundle} />;
  if (section === "Evidence table") return <CommandCards bundle={bundle} />;
  if (section === "Guided Ubuntu lab") return <LabCards bundle={bundle} />;
  return null;
}

function SectionSupplement({ section, bundle }: { section: string; bundle: StructuredLessonBundle }) {
  if (["Architecture map", "Failure zoom", "Evidence table", "Guided Ubuntu lab"].includes(section)) {
    return <StructuredOperationalSupplement bundle={bundle} section={section} />;
  }
  if (section === "Complete answers") return <div className={styles.answerList}>{bundle.assessments.filter((item): item is AnsweredAssessment => item.type !== "independent-transfer" && item.type !== "interview").map((item) => <AnsweredCard assessment={item} key={item.id} />)}</div>;
  if (section === "Product-company interview") return <div className={styles.answerList}>{bundle.assessments.filter((item): item is AnsweredAssessment => item.type === "interview").map((item) => <AnsweredCard assessment={item} key={item.id} />)}</div>;
  if (section === "Independent transfer and rubric") return <div>{bundle.assessments.filter((item): item is IndependentAssessment => item.type === "independent-transfer").map((item) => <IndependentCard assessment={item} key={item.id} />)}</div>;
  if (section === "References and review") return <ReferenceCards bundle={bundle} />;
  return null;
}

function PrerequisitePanel({
  context,
  lessonId,
}: {
  context: ReaderPrerequisiteContext;
  lessonId: string;
}) {
  if (context.lessons.length === 0 && context.curriculumIds.length === 0) return null;

  const panelId = `${lessonId.toLowerCase()}-prerequisites`;
  const descriptionId = `${panelId}-description`;
  const lessonsHeadingId = `${panelId}-lessons-heading`;
  const curriculumHeadingId = `${panelId}-curriculum-heading`;

  return (
    <aside
      aria-describedby={descriptionId}
      aria-labelledby={`${panelId}-heading`}
      className={styles.prerequisitePanel}
    >
      <header>
        <p>LEARNING PATH / ADVISORY</p>
        <h2 id={`${panelId}-heading`}>Recommended preparation</h2>
        <span id={descriptionId}>Review these dependencies first if the ideas feel unfamiliar. They guide your study order, but they never lock this lesson or claim mastery.</span>
      </header>
      <div className={styles.prerequisiteGrid}>
        {context.lessons.length > 0 ? (
          <nav aria-labelledby={lessonsHeadingId} className={styles.prerequisiteGroup}>
            <h3 id={lessonsHeadingId}>Earlier lessons</h3>
            <ul className={styles.prerequisiteLinks}>
              {context.lessons.map((prerequisite) => (
                <li key={prerequisite.canonicalId}>
                  <Link href={prerequisite.route}>
                    <strong>{prerequisite.title}</strong>
                    <span>Volume {prerequisite.volumeNumber} / Lesson {prerequisite.number} / {prerequisite.canonicalId}</span>
                  </Link>
                </li>
              ))}
            </ul>
          </nav>
        ) : null}
        {context.curriculumIds.length > 0 ? (
          <section aria-labelledby={curriculumHeadingId} className={styles.prerequisiteGroup}>
            <h3 id={curriculumHeadingId}>Curriculum dependencies</h3>
            <ul className={styles.curriculumIds}>
              {context.curriculumIds.map((curriculumId) => <li key={curriculumId}><code>{curriculumId}</code></li>)}
            </ul>
            <p>These IDs map this lesson into the wider curriculum. They are references, not completion badges.</p>
          </section>
        ) : null}
      </div>
    </aside>
  );
}

export default function StructuredLessonArticle({ bundle }: { bundle: StructuredLessonBundle }) {
  const { lesson } = bundle;
  const metadata = lesson.metadata;
  const adjacent = adjacentReaderEntries(metadata.slug);
  const entry = findReaderEntry(metadata.slug);
  if (!entry) throw new Error(`reader entry is missing for ${metadata.id}`);
  const prerequisites = resolveReaderPrerequisites(
    metadata.prerequisiteLessonIds,
    metadata.prerequisiteCurriculumIds,
  );
  const volumeLessons = readerEntriesForVolume(entry.volumeId);
  const labNetworks = [...new Set(metadata.labs.map((lab) => lab.network))].join(" / ");
  const volumeEndLink = entry.volumeId === "00-start-safely"
    ? <Link href="/book/linux">Continue: Volume 01 -&gt;</Link>
    : entry.volumeId === "01-linux-systems"
      ? <Link href="/book/connectivity">Continue: Volume 02 -&gt;</Link>
      : entry.volumeId === "02-connectivity"
        ? <Link href="/book/engineering">Continue: Volume 03 -&gt;</Link>
        : entry.volumeId === "03-engineering-delivery"
          ? <Link href="/book/reliability">Continue: Volume 04 -&gt;</Link>
          : <Link href="/book#knowledge-map">Continue through the knowledge map -&gt;</Link>;
  return (
    <article className={styles.article} id={metadata.slug}>
      <header className={styles.hero}>
        <div className={styles.lessonNumber}>{entry.number}</div>
        <div><p>VOLUME {entry.volumeNumber} / {metadata.id} / {metadata.contentStatus.replaceAll("-", " ").toUpperCase()}</p><h1>{metadata.title}</h1><span>{metadata.summary}</span></div>
      </header>
      <aside className={styles.masteryBoundary}><strong>AVAILABLE TO STUDY, NOT MASTERED</strong><span>Reading, revealing answers, copying commands, or marking this page finished never changes competency. Independent evidence still requires review.</span></aside>
      <div className={styles.factGrid}>
        <article><span>LEVEL</span><strong>{metadata.level.from} to {metadata.level.to}</strong></article>
        <article><span>STUDY TIME</span><strong>{metadata.estimatedMinutes} minutes</strong></article>
        <article><span>TESTED BASELINE</span><strong>{metadata.testedEnvironments[0].platform} {metadata.testedEnvironments[0].version}</strong></article>
        <article><span>NETWORK</span><strong>{labNetworks}</strong></article>
      </div>
      <StructuredLessonContext metadata={metadata} />
      <PrerequisitePanel context={prerequisites} lessonId={metadata.id} />
      <nav className={styles.jumpNav} aria-label={`${metadata.title} sections`}>{lesson.sections.map((section) => <a href={`#${section.anchor}`} key={section.anchor}>{section.title}</a>)}</nav>
      {lesson.sections.map((section, index) => (
        <section className={styles.section} id={section.anchor} key={section.anchor}>
          <header><span>{String(index + 1).padStart(2, "0")} / {metadata.id}</span><h2>{section.title}</h2></header>
          <MarkdownBlocks blocks={section.blocks} />
          <SectionSupplement bundle={bundle} section={section.title} />
        </section>
      ))}
      <aside className={styles.limitations}><strong>KNOWN LIMITATIONS</strong><ul>{metadata.limitations.map((item) => <li key={item}>{item}</li>)}</ul></aside>
      <nav className="lesson-pagination" aria-label={`Lesson ${metadata.order} navigation`}>
        {adjacent.previous ? <Link href={adjacent.previous.route}>&lt;- Previous: {adjacent.previous.number}</Link> : <Link href={entry.volumeRoute}>&lt;- Volume index</Link>}
        <Link href={entry.volumeRoute}>{volumeLessons.length}-lesson index</Link>
        {adjacent.next ? <Link href={adjacent.next.route}>Next: {adjacent.next.number} -&gt;</Link> : volumeEndLink}
      </nav>
    </article>
  );
}
