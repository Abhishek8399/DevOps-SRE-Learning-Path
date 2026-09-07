import RoutedLessonPage, { lessonStaticParams } from "../../../routed-lesson-page";

export function generateStaticParams() { return lessonStaticParams("08-security-engineering"); }

export default async function SecurityLessonPage({ params }: Readonly<{ params: Promise<{ lesson: string }> }>) {
  const { lesson } = await params;
  return <RoutedLessonPage lessonId={lesson} volumeId="08-security-engineering" />;
}
