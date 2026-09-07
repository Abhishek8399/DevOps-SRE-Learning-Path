import RoutedLessonPage, { lessonStaticParams } from "../../../routed-lesson-page";

export function generateStaticParams() { return lessonStaticParams("09-private-cloud"); }

export default async function PrivateCloudLessonPage({ params }: Readonly<{ params: Promise<{ lesson: string }> }>) {
  const { lesson } = await params;
  return <RoutedLessonPage lessonId={lesson} volumeId="09-private-cloud" />;
}
