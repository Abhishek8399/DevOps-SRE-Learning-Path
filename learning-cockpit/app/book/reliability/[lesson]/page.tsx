import RoutedLessonPage, { lessonStaticParams } from "../../../routed-lesson-page";

export function generateStaticParams() {
  return lessonStaticParams("04-reliability-operations");
}

export default async function ReliabilityLessonPage({
  params,
}: Readonly<{ params: Promise<{ lesson: string }> }>) {
  const { lesson } = await params;
  return <RoutedLessonPage lessonId={lesson} volumeId="04-reliability-operations" />;
}
