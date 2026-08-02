import type { Metadata } from "next";
import Link from "next/link";
import { readerCatalog } from "../lessons/reader-catalog";
import LearningLibrary, { type LearningLibraryLesson } from "./learning-library";
import { isLearningLessonId } from "./learning-state";
import styles from "./my-learning.module.css";

export const metadata: Metadata = {
  title: "My Learning | Reliability Atlas",
  description: "A device-local place to bookmark lessons and resume reading without changing mastery evidence.",
};

const lessons: LearningLibraryLesson[] = readerCatalog.map((lesson) => {
  if (!isLearningLessonId(lesson.stateId)) {
    throw new Error(`reader state identity is not trusted: ${lesson.stateId}`);
  }
  return {
    id: lesson.stateId,
    number: lesson.number,
    volumeNumber: lesson.volumeNumber,
    volumeTitle: lesson.volumeTitle,
    title: lesson.title,
    summary: lesson.summary,
    href: lesson.route,
  };
});

export default function MyLearningPage() {
  return (
    <main className={styles.page} id="main-content">
      <div className={styles.shell}>
        <nav className={styles.breadcrumbs} aria-label="Breadcrumb">
          <Link href="/">Home</Link>
          <span aria-hidden="true">/</span>
          <Link href="/book">Library</Link>
          <span aria-hidden="true">/</span>
          <b>My learning</b>
        </nav>

        <header className={styles.hero}>
          <div>
            <p className={styles.eyebrow}>DEVICE-LOCAL READING DESK</p>
            <h1>Return to the lesson that needs your attention.</h1>
            <p className={styles.intro}>
              Bookmark a lesson, remember where you opened the book, and label your reading state.
              These private convenience markers stay in this browser when storage is available.
            </p>
          </div>
          <aside className={styles.masteryBoundary} aria-label="Important evidence boundary">
            <span>IMPORTANT BOUNDARY</span>
            <strong>Finished reading is not verified mastery.</strong>
            <p>
              Nothing on this page changes assessments, lab evidence, competency gates, or the repository mastery ledger.
            </p>
          </aside>
        </header>

        <LearningLibrary lessons={lessons} />

        <aside className={styles.privacyNote}>
          <strong>What this page stores</strong>
          <p>
            Only fixed lesson IDs, bookmarks, reading markers, and recent-open timestamps. It has no free-text fields and never asks for employer data, commands, credentials, tokens, production evidence, or secrets. Browser storage is origin-specific, so <code>localhost</code>, <code>127.0.0.1</code>, and different ports keep separate markers.
          </p>
        </aside>
      </div>
    </main>
  );
}
