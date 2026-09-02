import Link from "next/link";
import EditorialCodeBlock from "./editorial-code-block";
import { headingAnchor, type MarkdownBlock, type MarkdownInline } from "./lessons/structured-lesson-parser";
import type { CareerPrimer } from "./career-primer.server";
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
    if (block.kind === "code") return <EditorialCodeBlock diagram={block.language === "text"} filename={block.filename} key={key} language={block.language} lineNumbers={block.lineNumbers} role={block.role} value={block.value} />;
    return <div aria-label="Scrollable technical table" className={styles.tableWrap} key={key} role="region" tabIndex={0}><table><thead><tr>{block.headers.map((header, headerIndex) => <th key={headerIndex} scope="col"><Inline content={header} /></th>)}</tr></thead><tbody>{block.rows.map((row, rowIndex) => <tr key={rowIndex}>{row.map((cell, cellIndex) => <td key={cellIndex}><Inline content={cell} /></td>)}</tr>)}</tbody></table></div>;
  })}</div>;
}

export default function CareerPrimerArticle({ primer }: { primer: CareerPrimer }) {
  return <article className="chapter-block"><nav className="breadcrumbs" aria-label="Breadcrumb"><Link href="/career">Career map</Link><span>/</span><b>{primer.title}</b></nav><header className="practice-page-heading"><p className="eyebrow">CAREER FIELD MANUAL</p><h1>{primer.title}</h1><p>Study guidance and local practice only. Reading this chapter does not create mastery evidence.</p></header><Blocks blocks={primer.blocks} /></article>;
}
