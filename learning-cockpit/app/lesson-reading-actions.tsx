"use client";

import Link from "next/link";
import { useEffect, useRef, useState } from "react";
import {
  LEARNING_LIBRARY_STORAGE_KEY,
  createEmptyLearningState,
  getBrowserLearningStorage,
  getLessonConvenienceState,
  loadLearningState,
  recordLessonOpened,
  saveLearningState,
  setLessonMarker,
  toggleLessonBookmark,
  type LearningLessonId,
  type LearningLibraryState,
} from "./my-learning/learning-state";
import styles from "./lesson-reading-actions.module.css";

type StorageMode = "checking" | "device" | "memory";

export default function LessonReadingActions({
  lessonId,
  title,
}: {
  lessonId: LearningLessonId;
  title: string;
}) {
  const [learningState, setLearningState] = useState<LearningLibraryState>(() =>
    createEmptyLearningState(),
  );
  const [storageMode, setStorageMode] = useState<StorageMode>("checking");
  const [recoveredInvalidData, setRecoveredInvalidData] = useState(false);
  const [announcement, setAnnouncement] = useState("");
  const stateRef = useRef(learningState);
  const storageRef = useRef<Storage | null>(null);

  useEffect(() => {
    const storage = getBrowserLearningStorage();
    const loaded = loadLearningState(storage);
    const openedState = recordLessonOpened(
      loaded.state,
      lessonId,
      new Date().toISOString(),
    );
    const saved = saveLearningState(loaded.storageAvailable ? storage : null, openedState);
    storageRef.current = saved ? storage : null;

    const hydrationFrame = window.requestAnimationFrame(() => {
      stateRef.current = openedState;
      setLearningState(openedState);
      setStorageMode(saved ? "device" : "memory");
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
  }, [lessonId]);

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

  const convenience = getLessonConvenienceState(learningState, lessonId);
  const finished = convenience.marker === "finished-reading";
  const ready = storageMode !== "checking";

  const toggleBookmark = () => {
    const next = toggleLessonBookmark(stateRef.current, lessonId);
    const bookmarked = getLessonConvenienceState(next, lessonId).bookmarked;
    commit(next, `${title} ${bookmarked ? "bookmarked" : "removed from bookmarks"}.`);
  };

  const toggleFinished = () => {
    const nextMarker = finished ? "reading" : "finished-reading";
    const next = setLessonMarker(stateRef.current, lessonId, nextMarker);
    commit(
      next,
      finished
        ? `${title} returned to the reading marker.`
        : `${title} marked finished reading. This is not mastery evidence.`,
    );
  };

  return (
    <aside className={styles.panel} aria-label={`Private reading controls for ${title}`}>
      <div className={styles.status}>
        <strong>PRIVATE READING DESK</strong>
        <span>
          {storageMode === "checking" && "Loading this browser's lesson markers..."}
          {storageMode === "device" && "Saved only in this browser on this device."}
          {storageMode === "memory" && "Browser storage unavailable: temporary on this page only."}
        </span>
      </div>
      <div className={styles.actions}>
        <button
          aria-label={`${convenience.bookmarked ? "Remove bookmark for" : "Bookmark"} ${title}`}
          aria-pressed={convenience.bookmarked}
          disabled={!ready}
          onClick={toggleBookmark}
          type="button"
        >
          {convenience.bookmarked ? "Bookmarked" : "Bookmark"}
        </button>
        <button
          aria-label={`${finished ? "Return to reading" : "Mark finished reading"}: ${title}`}
          aria-pressed={finished}
          disabled={!ready}
          onClick={toggleFinished}
          type="button"
        >
          {finished ? "Finished reading" : "Mark finished reading"}
        </button>
        <Link href="/my-learning">Open My Learning</Link>
      </div>
      <p>
        Opening this page records only its fixed lesson ID and a timestamp.
        Reading markers organise the book; they never change competency or mastery.
        {recoveredInvalidData ? " Invalid saved markers were reset safely." : ""}
      </p>
      <span className="sr-only" aria-live="polite">{announcement}</span>
    </aside>
  );
}
