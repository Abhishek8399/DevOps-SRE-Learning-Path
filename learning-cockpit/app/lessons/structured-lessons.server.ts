import lesson0006Raw from "../../../book/volumes/01-linux-systems/LES-0006-boot-kernel-systemd-journal/lesson.md?raw";
import assessment0001Value from "../../../book/assessments/linux/ASM-0001.json";
import assessment0002Value from "../../../book/assessments/linux/ASM-0002.json";
import assessment0003Value from "../../../book/assessments/linux/ASM-0003.json";
import reference0001Value from "../../../book/references/REF-0001.json";
import reference0002Value from "../../../book/references/REF-0002.json";
import reference0003Value from "../../../book/references/REF-0003.json";
import reference0004Value from "../../../book/references/REF-0004.json";
import reference0005Value from "../../../book/references/REF-0005.json";
import reference0006Value from "../../../book/references/REF-0006.json";
import reference0007Value from "../../../book/references/REF-0007.json";
import reference0008Value from "../../../book/references/REF-0008.json";
import {
  parseStructuredAssessment,
  parseStructuredLesson,
  parseStructuredReference,
  type StructuredLessonBundle,
} from "./structured-lesson-parser";

function unique(values: readonly string[], label: string): void {
  if (new Set(values).size !== values.length) throw new Error(`${label} contains duplicate IDs`);
}

function createBundle(): StructuredLessonBundle {
  const lesson = parseStructuredLesson(lesson0006Raw);
  const assessments = [
    assessment0001Value,
    assessment0002Value,
    assessment0003Value,
  ].map(parseStructuredAssessment);
  const references = [
    reference0001Value,
    reference0002Value,
    reference0003Value,
    reference0004Value,
    reference0005Value,
    reference0006Value,
    reference0007Value,
    reference0008Value,
  ].map(parseStructuredReference);
  const assessmentIds = assessments.map((record) => record.id);
  const referenceIds = references.map((record) => record.id);

  unique(assessmentIds, "structured assessment registry");
  unique(referenceIds, "structured reference registry");
  if (JSON.stringify(assessmentIds) !== JSON.stringify(lesson.metadata.assessmentIds)) {
    throw new Error(`${lesson.metadata.id} assessment registry differs from lesson metadata`);
  }
  if (JSON.stringify(referenceIds) !== JSON.stringify(lesson.metadata.referenceIds)) {
    throw new Error(`${lesson.metadata.id} reference registry differs from lesson metadata`);
  }
  for (const assessment of assessments) {
    if (assessment.lessonId !== lesson.metadata.id) {
      throw new Error(`${assessment.id} does not belong to ${lesson.metadata.id}`);
    }
  }
  for (const reference of references) {
    if (!reference.lessonIds.includes(lesson.metadata.id)) {
      throw new Error(`${reference.id} does not link back to ${lesson.metadata.id}`);
    }
  }
  if (!assessments.some((record) => record.type === "independent-transfer")) {
    throw new Error(`${lesson.metadata.id} has no independent transfer assessment`);
  }
  return { lesson, assessments, references };
}

export const structuredLessonBundles: readonly StructuredLessonBundle[] = [createBundle()];

export function findStructuredLesson(slug: string): StructuredLessonBundle | undefined {
  return structuredLessonBundles.find((bundle) => bundle.lesson.metadata.slug === slug);
}
