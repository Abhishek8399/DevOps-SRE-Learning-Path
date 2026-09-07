import RoutedLessonPage, { lessonStaticParams } from "../../../routed-lesson-page";

export function generateStaticParams() { return lessonStaticParams("11-capstones"); }

export default async function CapstoneLessonPage({ params }: Readonly<{ params: Promise<{ lesson: string }> }>) {
  const { lesson } = await params;
  return <RoutedLessonPage lessonId={lesson} volumeId="11-capstones" />;
}
