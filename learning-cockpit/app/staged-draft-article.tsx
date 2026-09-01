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

function Section({ section }: { section: StructuredSection }) {
  return <section className="chapter-block" id={section.anchor}><h2>{section.title}</h2><Blocks blocks={section.blocks} /></section>;
}

export default function StagedDraftArticle({ draft }: { draft: StagedDraft }) {
  const { lesson } = draft;
  return <article className="chapter-block"><nav className="breadcrumbs" aria-label="Breadcrumb"><Link href="/drafts">Staged drafts</Link><span>/</span><b>{lesson.title}</b></nav><header className="practice-page-heading"><p className="eyebrow">STAGED DRAFT â€” READING PREVIEW</p><h1>{lesson.title}</h1><p>{lesson.metadata.summary}</p><p><strong>Important:</strong> this is substantial teaching material, but it is not canonical publication, validated lab evidence, production proof, or mastery evidence. Follow only commands whose risks and prerequisites you understand.</p></header>{lesson.sections.map((section) => <Section key={section.title} section={section} />)}</article>;
}
