import RoutedLessonPage, { lessonStaticParams } from "../../../routed-lesson-page";

export function generateStaticParams() {
  return lessonStaticParams("02-connectivity");
}

export default async function ConnectivityLessonPage({
  params,
}: Readonly<{ params: Promise<{ lesson: string }> }>) {
  const { lesson } = await params;
  return <RoutedLessonPage lessonId={lesson} volumeId="02-connectivity" />;
}
