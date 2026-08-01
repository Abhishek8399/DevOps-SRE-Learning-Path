"use client";

import Link from "next/link";
import { useEffect, useMemo, useRef, useState } from "react";
import {
  LEARNING_LIBRARY_STORAGE_KEY,
  clearLearningState,
  createEmptyLearningState,
  getBrowserLearningStorage,
  getLessonConvenienceState,
  isReadingMarker,
  loadLearningState,
  recordLessonOpened,
  saveLearningState,
  setLessonMarker,
  toggleLessonBookmark,
  type LearningLessonId,
  type LearningLibraryState,
  type ReadingMarker,
} from "./learning-state";
import styles from "./my-learning.module.css";

export type LearningLibraryLesson = {
  id: LearningLessonId;
  number: string;
  title: string;
  summary: string;
  href: string;
};

type StorageMode = "checking" | "device" | "memory";

const markerLabels: Record<ReadingMarker, string> = {
  "not-started": "Not started",
  reading: "Reading",
  "finished-reading": "Finished reading (not mastery)",
};

function formatOpenedAt(value: string | null): string | null {
  if (!value) return null;
  const timestamp = new Date(value);
  if (Number.isNaN(timestamp.getTime())) return null;
  return new Intl.DateTimeFormat(undefined, {
    dateStyle: "medium",
    timeStyle: "short",
  }).format(timestamp);
}

export default function LearningLibrary({ lessons }: { lessons: LearningLibraryLesson[] }) {
  const [learningState, setLearningState] = useState<LearningLibraryState>(() =>
    createEmptyLearningState(),
  );
  const [storageMode, setStorageMode] = useState<StorageMode>("checking");
  const [recoveredInvalidData, setRecoveredInvalidData] = useState(false);
  const [showBookmarksOnly, setShowBookmarksOnly] = useState(false);
  const [confirmClear, setConfirmClear] = useState(false);
  const [announcement, setAnnouncement] = useState("");
  const stateRef = useRef(learningState);
  const storageRef = useRef<Storage | null>(null);
  const clearTriggerRef = useRef<HTMLButtonElement>(null);
  const confirmClearRef = useRef<HTMLButtonElement>(null);
  const returnClearFocusRef = useRef(false);

  useEffect(() => {
    const storage = getBrowserLearningStorage();
    const loaded = loadLearningState(storage);
    storageRef.current = loaded.storageAvailable ? storage : null;
    const hydrationFrame = window.requestAnimationFrame(() => {
      stateRef.current = loaded.state;
      setLearningState(loaded.state);
      setStorageMode(loaded.storageAvailable ? "device" : "memory");
      setRecoveredInvalidData(loaded.recoveredInvalidData);
    });

    const synchroniseAcrossTabs = (event: StorageEvent) => {
      if (event.key !== LEARNING_LIBRARY_STORAGE_KEY && event.key !== null) return;
      const currentStorage = getBrowserLearningStorage();
      const latest = loadLearningState(currentStorage);
      storageRef.current = latest.storageAvailable ? currentStorage : null;
      stateRef.current = latest.state;
      setLearningState(latest.state);
      setStorageMode(latest.storageAvailable ? "device" : "memory");
      setRecoveredInvalidData(latest.recoveredInvalidData);
    };

    window.addEventListener("storage", synchroniseAcrossTabs);
    return () => {
      window.cancelAnimationFrame(hydrationFrame);
      window.removeEventListener("storage", synchroniseAcrossTabs);
    };
  }, []);

  const lessonById = useMemo(
    () => new Map(lessons.map((lesson) => [lesson.id, lesson])),
    [lessons],
  );

  useEffect(() => {
    if (confirmClear) {
      confirmClearRef.current?.focus();
    } else if (returnClearFocusRef.current) {
      returnClearFocusRef.current = false;
      clearTriggerRef.current?.focus();
    }
  }, [confirmClear]);

  const commit = (next: LearningLibraryState, message: string) => {
    stateRef.current = next;
    setLearningState(next);
    const persisted = saveLearningState(storageRef.current, next);
    if (!persisted) {
      storageRef.current = null;
      setStorageMode("memory");
    }
    setRecoveredInvalidData(false);
    setAnnouncement(persisted
      ? message
      : `${message} Browser storage refused the change, so it is temporary on this page.`);
  };

  const closeClearConfirmation = () => {
    returnClearFocusRef.current = true;
    setConfirmClear(false);
  };

  const rememberOpen = (lesson: LearningLibraryLesson) => {
    const next = recordLessonOpened(stateRef.current, lesson.id, new Date().toISOString());
    commit(next, `${lesson.title} saved as your most recent lesson.`);
  };

  const changeMarker = (lesson: LearningLibraryLesson, value: string) => {
    if (!isReadingMarker(value)) return;
    const next = setLessonMarker(stateRef.current, lesson.id, value);
    commit(next, `${lesson.title}: ${markerLabels[value]}. This is a reading marker, not mastery evidence.`);
  };

  const toggleBookmark = (lesson: LearningLibraryLesson) => {
    const next = toggleLessonBookmark(stateRef.current, lesson.id);
    const bookmarked = getLessonConvenienceState(next, lesson.id).bookmarked;
    commit(next, `${lesson.title} ${bookmarked ? "bookmarked" : "removed from bookmarks"}.`);
  };

  const clearMarkers = () => {
    const storage = getBrowserLearningStorage();
    const clearedFromDevice = clearLearningState(storage);
    const next = createEmptyLearningState();
    stateRef.current = next;
    setLearningState(next);
    storageRef.current = clearedFromDevice ? storage : null;
    setStorageMode(clearedFromDevice ? "device" : "memory");
    setRecoveredInvalidData(false);
    setShowBookmarksOnly(false);
    setAnnouncement(clearedFromDevice
      ? "All device-local lesson markers were cleared. Mastery evidence was not changed."
      : "Visible markers were reset, but browser storage refused the clear. Old markers may return after reload; mastery evidence was not changed.");
    closeClearConfirmation();
  };

  const recentLessons = learningState.recentLessonIds
    .map((lessonId) => lessonById.get(lessonId))
    .filter((lesson): lesson is LearningLibraryLesson => lesson !== undefined);
  const resumeLesson = recentLessons[0] ?? null;

  const counts = lessons.reduce(
    (result, lesson) => {
      const state = getLessonConvenienceState(learningState, lesson.id);
      if (state.bookmarked) result.bookmarked += 1;
      if (state.marker === "reading") result.reading += 1;
      if (state.marker === "finished-reading") result.finished += 1;
      return result;
    },
    { bookmarked: 0, reading: 0, finished: 0 },
  );

  const visibleLessons = showBookmarksOnly
    ? lessons.filter((lesson) => getLessonConvenienceState(learningState, lesson.id).bookmarked)
    : lessons;

  return (
    <section className={styles.workspace} aria-labelledby="learning-workspace-heading">
      <h2 className="sr-only" id="learning-workspace-heading">My device-local learning workspace</h2>

      <div
        className={`${styles.storageNotice} ${storageMode === "memory" ? styles.storageWarning : ""}`}
        role={storageMode === "memory" ? "alert" : "status"}
      >
        <strong>
          {storageMode === "checking" && "Checking browser storage..."}
          {storageMode === "device" && "Saved only in this browser on this device"}
          {storageMode === "memory" && "Browser storage unavailable: temporary memory mode"}
        </strong>
        <span>
          {storageMode === "device"
            ? "No account, server, or cloud sync is used. Another browser or device will have different markers."
            : storageMode === "memory"
              ? "Your choices remain only on this open page and may disappear after navigation or reload."
              : "Your lesson content remains available while this check runs."}
        </span>
      </div>

      {recoveredInvalidData && (
        <p className={styles.recoveryNotice} role="alert">
          Saved markers were unreadable or from an unsupported format, so this page reset them safely. Lesson content and mastery evidence were not changed.
        </p>
      )}

      <div className={styles.overviewGrid}>
        <article className={styles.resumeCard}>
          <span className={styles.cardLabel}>RESUME READING</span>
          {resumeLesson ? (
            <>
              <p className={styles.lessonNumber}>Lesson {resumeLesson.number}</p>
              <h2>{resumeLesson.title}</h2>
              <p>
                Last opened {formatOpenedAt(getLessonConvenienceState(learningState, resumeLesson.id).lastOpenedAt) ?? "recently"}.
              </p>
              <Link href={resumeLesson.href} onClick={() => rememberOpen(resumeLesson)}>
                Continue lesson <span aria-hidden="true">-&gt;</span>
              </Link>
            </>
          ) : (
            <>
              <h2>No recent lesson yet</h2>
              <p>Open any lesson below. This page will remember it as your return point when device storage works.</p>
              <Link href={lessons[0].href} onClick={() => rememberOpen(lessons[0])}>
                Start with Lesson {lessons[0].number} <span aria-hidden="true">-&gt;</span>
              </Link>
            </>
          )}
        </article>

        <div className={styles.summaryPanel}>
          <span className={styles.cardLabel}>READING MARKERS</span>
          <dl>
            <div><dt>Bookmarks</dt><dd>{counts.bookmarked}</dd></div>
            <div><dt>Currently reading</dt><dd>{counts.reading}</dd></div>
            <div><dt>Finished reading</dt><dd>{counts.finished}</dd></div>
          </dl>
          <p>These totals organise reading only. They never calculate skill, competency, readiness, or mastery.</p>
        </div>
      </div>

      {recentLessons.length > 1 && (
        <nav className={styles.recentStrip} aria-label="Recently opened lessons">
          <strong>Recently opened</strong>
          <ol>
            {recentLessons.slice(1).map((lesson) => {
              const openedAt = getLessonConvenienceState(learningState, lesson.id).lastOpenedAt;
              const openedLabel = formatOpenedAt(openedAt);
              return (
                <li key={lesson.id}>
                  <Link href={lesson.href} onClick={() => rememberOpen(lesson)}>
                    {lesson.number}. {lesson.title}
                  </Link>
                  {openedAt && openedLabel ? (
                    <time dateTime={openedAt}>{openedLabel}</time>
                  ) : null}
                </li>
              );
            })}
          </ol>
        </nav>
      )}

      <div className={styles.libraryHeading}>
        <div>
          <span className={styles.cardLabel}>VOLUME 01 / LINUX SYSTEMS</span>
          <h2>Choose your next reading move</h2>
          <p>Open a lesson, bookmark it for later, or set a private reading marker.</p>
        </div>
        <button
          className={styles.filterButton}
          type="button"
          aria-pressed={showBookmarksOnly}
          onClick={() => setShowBookmarksOnly((current) => !current)}
        >
          {showBookmarksOnly ? "Show all lessons" : `Bookmarks only (${counts.bookmarked})`}
        </button>
      </div>

      {visibleLessons.length > 0 ? (
        <div className={styles.lessonGrid}>
          {visibleLessons.map((lesson) => {
            const convenience = getLessonConvenienceState(learningState, lesson.id);
            const titleId = `learning-lesson-${lesson.id}`;
            return (
              <article className={styles.lessonCard} key={lesson.id} aria-labelledby={titleId}>
                <div className={styles.lessonCardTopline}>
                  <span>LESSON {lesson.number}</span>
                  <button
                    type="button"
                    className={styles.bookmarkButton}
                    aria-pressed={convenience.bookmarked}
                    aria-label={`${convenience.bookmarked ? "Remove bookmark for" : "Bookmark"} ${lesson.title}`}
                    onClick={() => toggleBookmark(lesson)}
                  >
                    {convenience.bookmarked ? "Bookmarked" : "Bookmark"}
                  </button>
                </div>
                <h3 id={titleId}>{lesson.title}</h3>
                <p>{lesson.summary}</p>
                <div className={styles.markerControl}>
                  <label htmlFor={`marker-${lesson.id}`}>Private reading marker</label>
                  <select
                    id={`marker-${lesson.id}`}
                    value={convenience.marker}
                    onChange={(event) => changeMarker(lesson, event.target.value)}
                  >
                    <option value="not-started">Not started</option>
                    <option value="reading">Reading</option>
                    <option value="finished-reading">Finished reading (not mastery)</option>
                  </select>
                </div>
                <Link className={styles.openLesson} href={lesson.href} onClick={() => rememberOpen(lesson)}>
                  Open lesson <span aria-hidden="true">-&gt;</span>
                </Link>
              </article>
            );
          })}
        </div>
      ) : (
        <div className={styles.emptyState} role="status">
          <strong>No bookmarked lessons yet.</strong>
          <p>Show all lessons, then use a Bookmark button to build this short list.</p>
          <button type="button" onClick={() => setShowBookmarksOnly(false)}>Show all lessons</button>
        </div>
      )}

      <div className={styles.clearArea}>
        {!confirmClear ? (
          <button ref={clearTriggerRef} type="button" onClick={() => setConfirmClear(true)}>
            Clear device-local reading markers
          </button>
        ) : (
          <div className={styles.clearConfirmation} role="group" aria-label="Confirm marker reset">
            <p><strong>Clear bookmarks, reading markers, and recent history?</strong> Lesson content and mastery evidence will not be touched.</p>
            <div>
              <button ref={confirmClearRef} type="button" onClick={clearMarkers}>
                Yes, clear local markers
              </button>
              <button type="button" onClick={closeClearConfirmation}>Cancel</button>
            </div>
          </div>
        )}
      </div>
      <span className="sr-only" aria-live="polite">{announcement}</span>
    </section>
  );
}
