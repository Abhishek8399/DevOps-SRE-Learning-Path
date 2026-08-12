"use client";

import Link from "next/link";
import { useEffect, useMemo, useRef, useState } from "react";
import {
  searchLessons,
  type SearchDocument,
} from "./search-index";
import styles from "./search.module.css";

const exampleQueries = [
  "ENOSPC",
  "df -i",
  "SIGTERM",
  "exit 137",
  "curl -v",
  "UID 10001",
  "journalctl",
  "backpressure",
] as const;

function isEditableTarget(target: EventTarget | null): boolean {
  if (!(target instanceof HTMLElement)) return false;
  return target.isContentEditable
    || target.tagName === "INPUT"
    || target.tagName === "TEXTAREA"
    || target.tagName === "SELECT";
}

export default function SearchClient({
  documents,
}: {
  documents: readonly SearchDocument[];
}) {
  const [query, setQuery] = useState("");
  const inputRef = useRef<HTMLInputElement>(null);
  const results = useMemo(() => searchLessons(documents, query), [documents, query]);
  const hasQuery = query.trim().length > 0;

  useEffect(() => {
    const handleShortcut = (event: KeyboardEvent) => {
      const commandShortcut = (event.ctrlKey || event.metaKey)
        && event.key.toLocaleLowerCase("en") === "k";
      const slashShortcut = event.key === "/" && !isEditableTarget(event.target);

      if (commandShortcut || slashShortcut) {
        event.preventDefault();
        inputRef.current?.focus();
        return;
      }

      if (event.key === "Escape" && document.activeElement === inputRef.current) {
        if (query.length > 0) {
          event.preventDefault();
          setQuery("");
        } else {
          inputRef.current?.blur();
        }
      }
    };

    document.addEventListener("keydown", handleShortcut);
    return () => document.removeEventListener("keydown", handleShortcut);
  }, [query]);

  const resultMessage = !hasQuery
    ? "Search is ready."
    : results.length === 0
      ? `No manual entries found for ${query.trim()}.`
      : `${results.length} ${results.length === 1 ? "manual entry" : "manual entries"} found.`;

  return (
    <main className={styles.page} id="main-content">
      <nav className={styles.breadcrumbs} aria-label="Breadcrumb">
        <Link href="/">Home</Link>
        <span aria-hidden="true">/</span>
        <Link href="/book">Knowledge library</Link>
        <span aria-hidden="true">/</span>
        <b>Search</b>
      </nav>

      <header className={styles.hero}>
        <p>OFFLINE FIELD-MANUAL SEARCH</p>
        <h1>Find the signal before choosing the command.</h1>
        <span>
          Search all {documents.length} locally available manual entries by incident symptom,
          Linux command, technical term, route ID, or curriculum ID. Nothing is uploaded.
        </span>
      </header>

      <section className={styles.searchPanel} aria-labelledby="search-heading">
        <div className={styles.searchHeading}>
          <div>
            <p>SEARCH CURRENT CONTENT</p>
            <h2 id="search-heading">What did you observe?</h2>
          </div>
          <kbd aria-label="Keyboard shortcut: Control or Command K">Ctrl / Cmd K</kbd>
        </div>

        <form role="search" onSubmit={(event) => event.preventDefault()}>
          <label htmlFor="manual-search">Symptom, command, term, or lesson ID</label>
          <div className={styles.inputRow}>
            <input
              autoComplete="off"
              aria-describedby="search-hint"
              id="manual-search"
              maxLength={160}
              onChange={(event) => setQuery(event.target.value)}
              placeholder="Try: no space left, journalctl, LES-0006, LNX-005..."
              ref={inputRef}
              spellCheck={false}
              type="search"
              value={query}
            />
            {query.length > 0 ? (
              <button onClick={() => {
                setQuery("");
                inputRef.current?.focus();
              }} type="button">
                Clear search
              </button>
            ) : null}
          </div>
          <p className={styles.hint} id="search-hint">
            Press <kbd>/</kbd> outside a form to focus search. Press <kbd>Esc</kbd>
            to clear it. Multiple words must all appear in the same lesson.
          </p>
        </form>

        <div className={styles.examples} aria-label="Example searches">
          <span>TRY A SEARCH</span>
          {exampleQueries.map((example) => (
            <button key={example} onClick={() => {
              setQuery(example);
              inputRef.current?.focus();
            }} type="button">
              {example}
            </button>
          ))}
        </div>
      </section>

      <p className={styles.status} aria-live="polite" role="status">
        {resultMessage}
      </p>

      {!hasQuery ? (
        <section className={styles.emptyState} aria-labelledby="search-start-heading">
          <div>
            <span>START WITH EVIDENCE</span>
            <h2 id="search-start-heading">Use the words the system gave you.</h2>
            <p>
              Search an error such as <code>ENOSPC</code>, an observation such as
              <code>high load</code>, or a command such as <code>vmstat</code>. Search
              finds teaching material; it does not diagnose a live system for you.
            </p>
          </div>
          <ol>
            <li><strong>{documents.length}</strong><span>lessons indexed</span></li>
            <li><strong>Local</strong><span>no network request</span></li>
            <li><strong>Read-only</strong><span>no mastery state changed</span></li>
          </ol>
        </section>
      ) : results.length === 0 ? (
        <section className={styles.noResults} aria-labelledby="no-results-heading">
          <span>NO LOCAL MATCH</span>
          <h2 id="no-results-heading">Keep the evidence; broaden the wording.</h2>
          <p>
            Try one boundary at a time: the exact error, a command name, or one
            mechanism such as inode, route, OOM, PID, ACL, TLS, or journal. Only the
            {documents.length} locally published manual entries are searchable today.
          </p>
          <Link href="/book">Browse the knowledge library</Link>
        </section>
      ) : (
        <section className={styles.results} aria-label="Search results">
          {results.map(({ document, matches }) => (
            <article className={styles.resultCard} key={document.id}>
              <div className={styles.resultNumber} aria-hidden="true">
                {document.number}
              </div>
              <div className={styles.resultBody}>
                <div className={styles.resultMeta}>
                  <span>VOLUME {document.volumeNumber} / {document.volumeTitle.toUpperCase()} / {(document.kind ?? "lesson").toUpperCase()} {document.number}</span>
                  <code>{document.id}</code>
                </div>
                <h2><Link href={document.href}>{document.title}</Link></h2>
                <p>{document.subtitle}</p>
                <dl>
                  {matches.map((match) => (
                    <div key={`${match.category}-${match.value}`}>
                      <dt>{match.category}</dt>
                      <dd>{match.category === "Command" ? <code>{match.value}</code> : match.value}</dd>
                    </div>
                  ))}
                </dl>
                <Link className={styles.openLesson} href={document.href}>
                  Open {document.kind ?? "lesson"} <span aria-hidden="true">-&gt;</span>
                </Link>
              </div>
            </article>
          ))}
        </section>
      )}

      <aside className={styles.masteryNote}>
        <strong>Search is navigation, not evidence.</strong>
        <p>
          Opening or reading a result never marks a capability complete. The learner
          ledger changes only after the required practical evidence and assessment are verified.
        </p>
      </aside>
    </main>
  );
}
