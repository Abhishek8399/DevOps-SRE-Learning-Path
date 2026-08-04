"use client";

import Link from "next/link";
import { useEffect, useMemo, useRef, useState } from "react";
import {
  LEARNING_LIBRARY_STORAGE_KEY,
  createEmptyLearningState,
  getBrowserLearningStorage,
  getLessonConvenienceState,
  loadLearningState,
  recordLessonOpened,
  saveLearningState,
  type LearningLessonId,
  type LearningLibraryState,
} from "./my-learning/learning-state";

export type LibraryLesson = Readonly<{
  id: LearningLessonId;
  number: string;
  volumeNumber: string;
  title: string;
  href: string;
}>;

function ReadingLink({
  lesson,
  remember,
  children,
}: Readonly<{
  lesson: LibraryLesson;
  remember: (lesson: LibraryLesson) => void;
  children: React.ReactNode;
}>) {
  return <Link href={lesson.href} onClick={() => remember(lesson)}>{children}</Link>;
}

export default function LibraryReadingDesk({ lessons }: { lessons: LibraryLesson[] }) {
  const [state, setState] = useState<LearningLibraryState>(() => createEmptyLearningState());
  const [storageAvailable, setStorageAvailable] = useState(true);
  const stateRef = useRef(state);
  const storageRef = useRef<Storage | null>(null);
  const lessonById = useMemo(() => new Map(lessons.map((lesson) => [lesson.id, lesson])), [lessons]);

  useEffect(() => {
    const storage = getBrowserLearningStorage();
    const loaded = loadLearningState(storage);
    storageRef.current = loaded.storageAvailable ? storage : null;
    const frame = window.requestAnimationFrame(() => {
      stateRef.current = loaded.state;
      setState(loaded.state);
      setStorageAvailable(loaded.storageAvailable);
    });
    const synchronise = (event: StorageEvent) => {
      if (event.key !== LEARNING_LIBRARY_STORAGE_KEY && event.key !== null) return;
      const currentStorage = getBrowserLearningStorage();
      const latest = loadLearningState(currentStorage);
      storageRef.current = latest.storageAvailable ? currentStorage : null;
      stateRef.current = latest.state;
      setState(latest.state);
      setStorageAvailable(latest.storageAvailable);
    };
    window.addEventListener("storage", synchronise);
    return () => {
      window.cancelAnimationFrame(frame);
      window.removeEventListener("storage", synchronise);
    };
  }, []);

  const remember = (lesson: LibraryLesson) => {
    const next = recordLessonOpened(stateRef.current, lesson.id, new Date().toISOString());
    stateRef.current = next;
    setState(next);
    if (!saveLearningState(storageRef.current, next)) setStorageAvailable(false);
  };

  const recent = state.recentLessonIds
    .map((id) => lessonById.get(id))
    .filter((lesson): lesson is LibraryLesson => Boolean(lesson));
  const bookmarks = lessons.filter((lesson) => getLessonConvenienceState(state, lesson.id).bookmarked);
  const finished = lessons.filter((lesson) => getLessonConvenienceState(state, lesson.id).marker === "finished-reading");
  const current = recent[0] ?? lessons[0];
  const currentIndex = lessons.findIndex((lesson) => lesson.id === current.id);
  const recommended = lessons.find((lesson, index) =>
    index > currentIndex && getLessonConvenienceState(state, lesson.id).marker !== "finished-reading",
  ) ?? lessons.find((lesson) => getLessonConvenienceState(state, lesson.id).marker !== "finished-reading") ?? current;
  const readingPercent = lessons.length ? Math.round((finished.length / lessons.length) * 100) : 0;

  return (
    <section className="library-desk" aria-labelledby="reading-desk-title">
      <div className="library-desk-heading">
        <div>
          <span>Private reading desk</span>
          <h2 id="reading-desk-title">Return to the work, not the dashboard.</h2>
        </div>
        <small>{storageAvailable ? "Stored only in this browser" : "Temporary memory mode"}</small>
      </div>
      <div className="library-desk-grid">
        <article className="continue-reading">
          <span>Continue reading · V{current.volumeNumber} / {current.number}</span>
          <h3>{current.title}</h3>
          <ReadingLink lesson={current} remember={remember}>Open at your last chapter <b aria-hidden="true">→</b></ReadingLink>
        </article>
        <article className="reading-progress-card">
          <span>Reading progress</span>
          <strong>{readingPercent}%</strong>
          <div aria-label={`${finished.length} of ${lessons.length} lessons marked finished reading`} role="progressbar" aria-valuemin={0} aria-valuemax={lessons.length} aria-valuenow={finished.length}>
            <i style={{ width: `${readingPercent}%` }} />
          </div>
          <p>{finished.length} of {lessons.length} available lessons marked finished. Reading is not mastery evidence.</p>
        </article>
        <article className="recommended-reading">
          <span>Recommended next</span>
          <h3>{recommended.title}</h3>
          <ReadingLink lesson={recommended} remember={remember}>Read next <b aria-hidden="true">→</b></ReadingLink>
        </article>
      </div>
      <div className="library-memory">
        <section aria-labelledby="recent-title">
          <div><h3 id="recent-title">Recently studied</h3><Link href="/my-learning">Full history</Link></div>
          {recent.length ? (
            <ol>{recent.slice(0, 3).map((lesson) => (
              <li key={lesson.id}><ReadingLink lesson={lesson} remember={remember}><b>V{lesson.volumeNumber}.{lesson.number}</b><span>{lesson.title}</span></ReadingLink></li>
            ))}</ol>
          ) : <p>Your last three opened lessons will appear here.</p>}
        </section>
        <section aria-labelledby="bookmarks-title">
          <div><h3 id="bookmarks-title">Bookmarks</h3><Link href="/my-learning">Manage</Link></div>
          {bookmarks.length ? (
            <ol>{bookmarks.slice(0, 3).map((lesson) => (
              <li key={lesson.id}><ReadingLink lesson={lesson} remember={remember}><b>V{lesson.volumeNumber}.{lesson.number}</b><span>{lesson.title}</span></ReadingLink></li>
            ))}</ol>
          ) : <p>Bookmark a lesson from its reading desk and it will wait here.</p>}
        </section>
      </div>
      <p className="mastery-ledger-note"><strong>Mastery ledger:</strong> This shelf records reading convenience only. Competence requires lab evidence, explanation, and review; it is never inferred from page visits.</p>
    </section>
  );
}
