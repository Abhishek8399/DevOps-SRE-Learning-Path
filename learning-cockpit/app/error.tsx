"use client";

import Link from "next/link";
import styles from "./recovery-page.module.css";

export default function AppError({ reset }: { reset: () => void }) {
  return (
    <main className={styles.page} id="main-content">
      <section className={styles.panel} aria-labelledby="reader-error-title" aria-live="assertive">
        <p className={styles.eyebrow}>LOCAL READER / RENDERING ERROR</p>
        <h1 id="reader-error-title">The reader could not render this page.</h1>
        <p className={styles.lede}>
          Retry once in case a development rebuild was still finishing. If the same
          page fails again, return to a stable index and run the validation commands
          below. No hidden recovery action or mastery change has occurred.
        </p>
        <div className={styles.actions}>
          <button onClick={reset} type="button">Retry this page</button>
          <Link href="/book">Return to the library</Link>
          <Link href="/search">Search another chapter</Link>
        </div>
        <aside className={styles.nextSteps}>
          <strong>IF RETRY FAILS AGAIN</strong>
          <p>
            Stop the local server with <code>Ctrl+C</code>. From <code>learning-cockpit</code>,
            run <code>npm run validate:content</code>, then <code>npm run typecheck</code>.
            Fix the first reported error before restarting; do not delete learning files
            or bypass validation.
          </p>
        </aside>
      </section>
    </main>
  );
}
