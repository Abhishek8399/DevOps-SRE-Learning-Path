import RoutedLessonPage, { lessonStaticParams } from "../../../routed-lesson-page";

export function generateStaticParams() {
  return lessonStaticParams("00-start-safely");
}

export default async function StartSafelyLessonPage({
  params,
}: Readonly<{ params: Promise<{ lesson: string }> }>) {
  const { lesson } = await params;
  return <RoutedLessonPage lessonId={lesson} volumeId="00-start-safely" />;
}
