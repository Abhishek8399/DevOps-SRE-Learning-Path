import Link from "next/link";
import styles from "./recovery-page.module.css";

export default function NotFound() {
  return (
    <main className={styles.page} id="main-content">
      <section className={styles.panel} aria-labelledby="not-found-title">
        <p className={styles.eyebrow}>404 / ROUTE NOT FOUND</p>
        <h1 id="not-found-title">This page is not in the local edition.</h1>
        <p className={styles.lede}>
          The link may be incomplete, an old bookmark may point to a renamed draft,
          or the chapter may not be published at this route. Your local reading
          markers and notes have not been changed.
        </p>
        <nav className={styles.actions} aria-label="Page recovery choices">
          <Link href="/book">Open the knowledge library</Link>
          <Link href="/search">Search the local manual</Link>
          <Link href="/drafts">Browse extended chapters</Link>
        </nav>
        <aside className={styles.nextSteps}>
          <strong>RECOVER WITHOUT GUESSING</strong>
          <ol>
            <li>Search the exact lesson ID or the main technical term from the old link.</li>
            <li>Use the library if you know the volume but not the chapter route.</li>
            <li>Use Extended chapters for complete drafts that are visible but not yet canonical.</li>
          </ol>
        </aside>
      </section>
    </main>
  );
}
