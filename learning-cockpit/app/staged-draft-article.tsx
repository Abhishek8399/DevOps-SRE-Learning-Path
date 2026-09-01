import Link from "next/link";
import EditorialCodeBlock from "./editorial-code-block";
import LessonReadingActions from "./lesson-reading-actions";
import {
  headingAnchor,
  type AnsweredAssessment,
  type IndependentAssessment,
  type MarkdownBlock,
  type MarkdownInline,
  type StructuredSection,
} from "./lessons/structured-lesson-parser";
import type { StagedDraft } from "./staged-draft.server";
import { isLearningLessonId } from "./my-learning/learning-state";
import styles from "./structured-lesson.module.css";

function Inline({ content }: { content: readonly MarkdownInline[] }) {
  return content.map((item, index) => item.kind === "strong" ? <strong key={index}>{item.text}</strong>
    : item.kind === "code" ? <code key={index}>{item.text}</code>
      : item.kind === "link" && item.href ? <a href={item.href} key={index} rel="noreferrer" target="_blank">{item.text}</a>
        : <span key={index}>{item.text}</span>);
}

function Blocks({ blocks }: { blocks: readonly MarkdownBlock[] }) {
  return <div className={styles.markdown}>{blocks.map((block, index) => {
    const key = `${block.kind}-${index}`;
    if (block.kind === "heading") { const text = block.content.map((item) => item.text).join(""); return block.level === 3 ? <h3 id={headingAnchor(text)} key={key}><Inline content={block.content} /></h3> : <h4 key={key}><Inline content={block.content} /></h4>; }
    if (block.kind === "paragraph") return <p key={key}><Inline content={block.content} /></p>;
    if (block.kind === "quote") return <blockquote key={key}><Inline content={block.content} /></blockquote>;
    if (block.kind === "unordered-list" || block.kind === "ordered-list") { const List = block.kind === "ordered-list" ? "ol" : "ul"; return <List key={key}>{block.items.map((item, itemIndex) => <li key={itemIndex}><Inline content={item} /></li>)}</List>; }
    if (block.kind === "code") return <EditorialCodeBlock diagram={block.language === "text"} key={key} language={block.language} value={block.value} />;
    return <div aria-label="Scrollable technical table" className={styles.tableWrap} key={key} role="region" tabIndex={0}><table><thead><tr>{block.headers.map((header, headerIndex) => <th key={headerIndex} scope="col"><Inline content={header} /></th>)}</tr></thead><tbody>{block.rows.map((row, rowIndex) => <tr key={rowIndex}>{row.map((cell, cellIndex) => <td key={cellIndex}><Inline content={cell} /></td>)}</tr>)}</tbody></table></div>;
  })}</div>;
}

function Section({ lessonId, number, section }: { lessonId: string; number: number; section: StructuredSection }) {
  return <section className={styles.section} id={section.anchor}><header><span>{String(number).padStart(2, "0")} / {lessonId}</span><h2>{section.title}</h2></header><Blocks blocks={section.blocks} /></section>;
}

function AnsweredPractice({ assessment }: { assessment: AnsweredAssessment }) {
  return <details className={`${styles.answerCard} ${styles.draftAnswerCard}`}>
    <summary><div><span>{assessment.id} / {assessment.type.replaceAll("-", " ")} / {assessment.difficulty}</span><h3>{assessment.prompt}</h3></div><b>Reveal the teaching answer</b></summary>
    <section className={styles.directAnswer}><strong>THE DIRECT ANSWER</strong><p>{assessment.directAnswer}</p></section>
    <section><strong>BUILD THE FOUNDATION</strong><p>{assessment.foundation}</p></section>
    <section><strong>REASONING, STEP BY STEP</strong><ol>{assessment.reasoningSteps.map((step) => <li key={step}>{step}</li>)}</ol></section>
    <section className={styles.seniorAnswer}><strong>HOW A SENIOR ENGINEER WOULD ANSWER</strong><p>{assessment.seniorAnswer}</p></section>
    <div className={styles.weakAnswer}><section><strong>COMMON WEAK ANSWER</strong><p>{assessment.weakAnswer}</p></section><section><strong>WHY IT IS WEAK</strong><p>{assessment.whyWeak}</p></section></div>
    <section><strong>EVIDENCE BOUNDARIES</strong><div className={styles.assessmentEvidence}>{assessment.evidence.map((item) => <article key={item.signal}><h4>{item.signal}</h4><p><b>Proves:</b> {item.proves}</p><p><b>Does not prove:</b> {item.doesNotProve}</p></article>)}</div></section>
    <section><strong>ANSWERED FOLLOW-UPS</strong><dl className={styles.followUps}>{assessment.followUps.map((item) => <div key={item.prompt}><dt>{item.prompt}</dt><dd>{item.answer}</dd></div>)}</dl></section>
    <section className={styles.rubric}><strong>REVIEW RUBRIC / {assessment.maximumScore} POINTS</strong>{assessment.rubric.map((row) => <div key={row.criterion}><b>{row.criterion} / {row.points}</b><p>{row.observableEvidence}</p></div>)}</section>
  </details>;
}

function IndependentPractice({ assessment }: { assessment: IndependentAssessment }) {
  return <article className={`${styles.independentCard} ${styles.draftIndependentCard}`}>
    <header><span>{assessment.id} / ANSWER-ISOLATED / {assessment.difficulty}</span><h3>{assessment.prompt}</h3></header>
    <p className={styles.noAnswer}>No model answer is stored or rendered. Work from the chapter, collect only sanitized evidence, and use the rubric to review your own reasoning.</p>
    <div className={styles.safetyColumns}><section><strong>DELIVERABLES</strong><ol>{assessment.deliverables.map((item) => <li key={item}>{item}</li>)}</ol></section><section><strong>EVIDENCE REQUIREMENTS</strong><ul>{assessment.evidenceRequirements.map((item) => <li key={item}>{item}</li>)}</ul></section></div>
    <section className={styles.rubric}><strong>OBSERVABLE RUBRIC / {assessment.maximumScore} POINTS</strong>{assessment.rubric.map((row) => <div key={row.criterion}><b>{row.criterion} / {row.points}</b><p>{row.observableEvidence}</p></div>)}</section>
  </article>;
}

function ReferenceShelf({ draft }: { draft: StagedDraft }) {
  return <details className={styles.draftContents}>
    <summary>Authoritative sources <span>{draft.references.length} checked-in records</span></summary>
    <div className={styles.references}>{draft.references.map((reference) => <article key={reference.id}>
      <span>{reference.id} / {reference.sourceType}</span>
      <h3><a href={reference.url} rel="noreferrer" target="_blank">{reference.title}</a></h3>
      <p>{reference.organization} / {reference.versionOrDate}</p>
      <p>{reference.relevance}</p>
      <small>Reviewed {reference.lastReviewed}; review after {reference.reviewAfter}</small>
    </article>)}</div>
  </details>;
}

export default function StagedDraftArticle({
  adjacent,
  draft,
}: {
  adjacent: Readonly<{ previous: StagedDraft | undefined; next: StagedDraft | undefined }>;
  draft: StagedDraft;
}) {
  const { lesson } = draft;
  const metadata = lesson.metadata;
  if (!isLearningLessonId(metadata.id)) {
    throw new Error(`staged reader state identity is not trusted: ${metadata.id}`);
  }
  const labMinutes = metadata.labs.reduce((total, lab) => total + lab.timeMinutes, 0);
  const prerequisites = [...metadata.prerequisiteLessonIds, ...metadata.prerequisiteCurriculumIds];
  return <article className={styles.article} id={draft.slug}>
    <nav className="breadcrumbs" aria-label="Breadcrumb"><Link href="/drafts">Staged drafts</Link><span>/</span><b>{lesson.title}</b></nav>
    <header className={styles.hero}>
      <div className={styles.lessonNumber}>{metadata.order}</div>
      <div><p>VOLUME {metadata.volume.slice(0, 2)} / {metadata.id} / STAGED READING PREVIEW</p><h1>{lesson.title}</h1><span>{metadata.summary}</span></div>
    </header>
    <aside className={styles.masteryBoundary}><strong>READABLE DRAFT, NOT A VERIFIED CLAIM</strong><span>This chapter is substantial teaching material. It is not canonical publication, validated lab evidence, production proof, or mastery evidence. Follow only commands whose risks and prerequisites you understand.</span></aside>
    <LessonReadingActions lessonId={metadata.id} title={lesson.title} />
    <div className={styles.factGrid}>
      <article><span>LEVEL</span><strong>{metadata.level.from} to {metadata.level.to}</strong></article>
      <article><span>STUDY TIME</span><strong>{metadata.estimatedMinutes} minutes</strong></article>
      <article><span>OBJECTIVES</span><strong>{metadata.learningObjectives.length} outcomes</strong></article>
      <article><span>LOCAL LAB TIME</span><strong>{labMinutes} minutes</strong></article>
    </div>
    <aside className={styles.draftCompass}>
      <section>
        <strong>BEFORE YOU BEGIN</strong>
        {prerequisites.length ? <ul>{prerequisites.map((id) => <li key={id}><code>{id}</code></li>)}</ul> : <p>No earlier chapter is required. Start slowly and validate each new term as you go.</p>}
      </section>
      <section>
        <strong>BY THE END, YOU SHOULD BE ABLE TO</strong>
        <ul>{metadata.learningObjectives.map((objective) => <li key={objective}>{objective}</li>)}</ul>
      </section>
    </aside>
    <details className={styles.draftContents}>
      <summary>Chapter contents <span>{lesson.sections.length} sections</span></summary>
      <nav aria-label={`${lesson.title} contents`}>{lesson.sections.map((section, index) => <a href={`#${section.anchor}`} key={section.anchor}><span>{String(index + 1).padStart(2, "0")}</span>{section.title}</a>)}</nav>
    </details>
    <details className={styles.draftContents}>
      <summary>Practice prompts <span>{draft.assessments.length} local assessments</span></summary>
      <div className={styles.draftAssessments}>{draft.assessments.map((assessment) => assessment.type === "independent-transfer"
        ? <IndependentPractice assessment={assessment} key={assessment.id} />
        : <AnsweredPractice assessment={assessment} key={assessment.id} />)}</div>
    </details>
    {lesson.sections.map((section, index) => <Section key={section.title} lessonId={metadata.id} number={index + 1} section={section} />)}
    <ReferenceShelf draft={draft} />
    <aside className={styles.limitations}><strong>KNOWN LIMITATIONS</strong><ul>{metadata.limitations.map((item) => <li key={item}>{item}</li>)}</ul></aside>
    <nav className="lesson-pagination" aria-label="Staged chapter navigation">
      {adjacent.previous ? <Link href={`/drafts/${adjacent.previous.slug}`}>&lt;- Previous chapter</Link> : <Link href="/drafts">&lt;- Staged library</Link>}
      <Link href="/drafts">All staged chapters</Link>
      {adjacent.next ? <Link href={`/drafts/${adjacent.next.slug}`}>Next chapter -&gt;</Link> : <Link href="/book">Canonical library -&gt;</Link>}
    </nav>
  </article>;
}
