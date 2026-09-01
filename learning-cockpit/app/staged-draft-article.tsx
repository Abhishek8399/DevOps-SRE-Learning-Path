import Link from "next/link";
import EditorialCodeBlock from "./editorial-code-block";
import {
  headingAnchor,
  type MarkdownBlock,
  type MarkdownInline,
  type StructuredSection,
} from "./lessons/structured-lesson-parser";
import type { StagedDraft } from "./staged-draft.server";
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

export default function StagedDraftArticle({
  adjacent,
  draft,
}: {
  adjacent: Readonly<{ previous: StagedDraft | undefined; next: StagedDraft | undefined }>;
  draft: StagedDraft;
}) {
  const { lesson } = draft;
  const metadata = lesson.metadata;
  const labMinutes = metadata.labs.reduce((total, lab) => total + lab.timeMinutes, 0);
  const prerequisites = [...metadata.prerequisiteLessonIds, ...metadata.prerequisiteCurriculumIds];
  return <article className={styles.article} id={draft.slug}>
    <nav className="breadcrumbs" aria-label="Breadcrumb"><Link href="/drafts">Staged drafts</Link><span>/</span><b>{lesson.title}</b></nav>
    <header className={styles.hero}>
      <div className={styles.lessonNumber}>{metadata.order}</div>
      <div><p>VOLUME {metadata.volume.slice(0, 2)} / {metadata.id} / STAGED READING PREVIEW</p><h1>{lesson.title}</h1><span>{metadata.summary}</span></div>
    </header>
    <aside className={styles.masteryBoundary}><strong>READABLE DRAFT, NOT A VERIFIED CLAIM</strong><span>This chapter is substantial teaching material. It is not canonical publication, validated lab evidence, production proof, or mastery evidence. Follow only commands whose risks and prerequisites you understand.</span></aside>
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
    {lesson.sections.map((section, index) => <Section key={section.title} lessonId={metadata.id} number={index + 1} section={section} />)}
    <aside className={styles.limitations}><strong>KNOWN LIMITATIONS</strong><ul>{metadata.limitations.map((item) => <li key={item}>{item}</li>)}</ul></aside>
    <nav className="lesson-pagination" aria-label="Staged chapter navigation">
      {adjacent.previous ? <Link href={`/drafts/${adjacent.previous.slug}`}>&lt;- Previous chapter</Link> : <Link href="/drafts">&lt;- Staged library</Link>}
      <Link href="/drafts">All staged chapters</Link>
      {adjacent.next ? <Link href={`/drafts/${adjacent.next.slug}`}>Next chapter -&gt;</Link> : <Link href="/book">Canonical library -&gt;</Link>}
    </nav>
  </article>;
}
