import Link from "next/link";
import { notFound } from "next/navigation";
import { FoundationLessonArticle } from "./foundation-volume";
import LessonReadingActions from "./lesson-reading-actions";
import { foundationLessons } from "./lessons/foundation-lessons";
import {
  findReaderEntry,
  readerEntriesForVolume,
  type ReaderVolumeId,
} from "./lessons/reader-catalog";
import { findStructuredLesson } from "./lessons/structured-lessons.server";
import { isLearningLessonId } from "./my-learning/learning-state";
import StorageChapter from "./storage-chapter";
import StructuredLessonArticle from "./structured-lesson";

export function lessonStaticParams(volumeId: ReaderVolumeId) {
  return readerEntriesForVolume(volumeId).map((entry) => ({ lesson: entry.slug }));
}

export default function RoutedLessonPage({
  lessonId,
  volumeId,
}: Readonly<{ lessonId: string; volumeId: ReaderVolumeId }>) {
  const entry = findReaderEntry(lessonId);
  if (!entry || entry.volumeId !== volumeId) notFound();
  if (!isLearningLessonId(entry.stateId)) {
    throw new Error(`reader state identity is not trusted: ${entry.stateId}`);
  }

  const breadcrumbs = (
    <nav className="breadcrumbs" aria-label="Breadcrumb">
      <Link href="/book">Library</Link><span>/</span>
      <Link href={entry.volumeRoute}>{entry.volumeTitle}</Link><span>/</span>
      <b>{entry.renderKind === "legacy-storage" ? "Storage" : `Lesson ${entry.number}`}</b>
    </nav>
  );
  const readingActions = (
    <LessonReadingActions lessonId={entry.stateId} title={entry.title} />
  );

  if (entry.renderKind === "legacy-storage") {
    return (
      <>
        {breadcrumbs}
        {readingActions}
        <StorageChapter />
      </>
    );
  }

  if (entry.renderKind === "legacy-foundation") {
    const lesson = foundationLessons.find((item) => item.id === entry.slug);
    if (!lesson) throw new Error(`legacy lesson content is missing: ${entry.canonicalId}`);
    return (
      <>
        {breadcrumbs}
        {readingActions}
        <FoundationLessonArticle lesson={lesson} />
      </>
    );
  }

  const bundle = findStructuredLesson(entry.slug);
  if (!bundle) throw new Error(`structured lesson bundle is missing: ${entry.canonicalId}`);
  return (
    <>
      {breadcrumbs}
      {readingActions}
      <StructuredLessonArticle bundle={bundle} />
    </>
  );
}
