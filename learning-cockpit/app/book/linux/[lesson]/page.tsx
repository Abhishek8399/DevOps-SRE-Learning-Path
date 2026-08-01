import Link from "next/link";
import { notFound } from "next/navigation";
import { FoundationLessonArticle } from "../../../foundation-volume";
import { foundationLessons } from "../../../lessons/foundation-lessons";
import StorageChapter from "../../../storage-chapter";

export function generateStaticParams() {
  return [{ lesson: "storage" }, ...foundationLessons.map((item) => ({ lesson: item.id }))];
}
export default async function LinuxLessonPage({ params }: { params: Promise<{ lesson: string }> }) {
  const { lesson: lessonId } = await params;

  if (lessonId === "storage") {
    return (
      <>
        <nav className="breadcrumbs" aria-label="Breadcrumb"><Link href="/book">Library</Link><span>/</span><Link href="/book/linux">Linux systems</Link><span>/</span><b>Storage</b></nav>
        <StorageChapter />
      </>
    );
  }

  const lesson = foundationLessons.find((item) => item.id === lessonId);
  if (!lesson) notFound();

  return (
    <>
      <nav className="breadcrumbs" aria-label="Breadcrumb"><Link href="/book">Library</Link><span>/</span><Link href="/book/linux">Linux systems</Link><span>/</span><b>Lesson {lesson.number}</b></nav>
      <FoundationLessonArticle lesson={lesson} />
    </>
  );
}
