import RoutedLessonPage, { lessonStaticParams } from "../../../routed-lesson-page";

export function generateStaticParams() {
  return lessonStaticParams("07-ai-engineering");
}

export default async function AiLessonPage({
  params,
}: Readonly<{ params: Promise<{ lesson: string }> }>) {
  const { lesson } = await params;
  return <RoutedLessonPage lessonId={lesson} volumeId="07-ai-engineering" />;
}
