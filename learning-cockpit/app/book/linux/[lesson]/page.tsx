import RoutedLessonPage, { lessonStaticParams } from "../../../routed-lesson-page";

export function generateStaticParams() {
  return lessonStaticParams("01-linux-systems");
}

export default async function LinuxLessonPage({
  params,
}: Readonly<{ params: Promise<{ lesson: string }> }>) {
  const { lesson } = await params;
  return <RoutedLessonPage lessonId={lesson} volumeId="01-linux-systems" />;
}
