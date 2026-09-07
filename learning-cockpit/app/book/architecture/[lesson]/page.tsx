import RoutedLessonPage, { lessonStaticParams } from "../../../routed-lesson-page";

export function generateStaticParams() { return lessonStaticParams("10-architecture-leadership"); }

export default async function ArchitectureLessonPage({ params }: Readonly<{ params: Promise<{ lesson: string }> }>) {
  const { lesson } = await params;
  return <RoutedLessonPage lessonId={lesson} volumeId="10-architecture-leadership" />;
}
