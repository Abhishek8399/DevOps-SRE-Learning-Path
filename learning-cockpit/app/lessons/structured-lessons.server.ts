import lesson0006Raw from "virtual:book-lesson/LES-0006";
import lesson0007Raw from "virtual:book-lesson/LES-0007";
import assessment0001Value from "../../../book/assessments/linux/ASM-0001.json";
import assessment0002Value from "../../../book/assessments/linux/ASM-0002.json";
import assessment0003Value from "../../../book/assessments/linux/ASM-0003.json";
import assessment0004Value from "../../../book/assessments/foundations/ASM-0004.json";
import assessment0005Value from "../../../book/assessments/foundations/ASM-0005.json";
import assessment0006Value from "../../../book/assessments/foundations/ASM-0006.json";
import reference0001Value from "../../../book/references/REF-0001.json";
import reference0002Value from "../../../book/references/REF-0002.json";
import reference0003Value from "../../../book/references/REF-0003.json";
import reference0004Value from "../../../book/references/REF-0004.json";
import reference0005Value from "../../../book/references/REF-0005.json";
import reference0006Value from "../../../book/references/REF-0006.json";
import reference0007Value from "../../../book/references/REF-0007.json";
import reference0008Value from "../../../book/references/REF-0008.json";
import reference0009Value from "../../../book/references/REF-0009.json";
import reference0010Value from "../../../book/references/REF-0010.json";
import reference0011Value from "../../../book/references/REF-0011.json";
import reference0012Value from "../../../book/references/REF-0012.json";
import reference0013Value from "../../../book/references/REF-0013.json";
import reference0014Value from "../../../book/references/REF-0014.json";
import reference0015Value from "../../../book/references/REF-0015.json";
import reference0016Value from "../../../book/references/REF-0016.json";
import {
  parseStructuredAssessment,
  parseStructuredLesson,
  parseStructuredReference,
  type StructuredAssessment,
  type StructuredLessonBundle,
  type StructuredReference,
} from "./structured-lesson-parser";

function indexById<T extends Readonly<{ id: string }>>(
  records: readonly T[],
  label: string,
): ReadonlyMap<string, T> {
  const index = new Map(records.map((record) => [record.id, record]));
  if (index.size !== records.length) throw new Error(`${label} contains duplicate IDs`);
  return index;
}

function requireRecord<T>(
  index: ReadonlyMap<string, T>,
  id: string,
  label: string,
): T {
  const record = index.get(id);
  if (!record) throw new Error(`${label} is missing ${id}`);
  return record;
}

const assessmentRegistry: readonly StructuredAssessment[] = [
  assessment0001Value,
  assessment0002Value,
  assessment0003Value,
  assessment0004Value,
  assessment0005Value,
  assessment0006Value,
].map(parseStructuredAssessment);

const referenceRegistry: readonly StructuredReference[] = [
  reference0001Value,
  reference0002Value,
  reference0003Value,
  reference0004Value,
  reference0005Value,
  reference0006Value,
  reference0007Value,
  reference0008Value,
  reference0009Value,
  reference0010Value,
  reference0011Value,
  reference0012Value,
  reference0013Value,
  reference0014Value,
  reference0015Value,
  reference0016Value,
].map(parseStructuredReference);

const assessmentsById = indexById(assessmentRegistry, "structured assessment registry");
const referencesById = indexById(referenceRegistry, "structured reference registry");

function createBundle(rawLesson: string): StructuredLessonBundle {
  const lesson = parseStructuredLesson(rawLesson);
  const assessments = lesson.metadata.assessmentIds.map((id) =>
    requireRecord(assessmentsById, id, `${lesson.metadata.id} assessment registry`));
  const references = lesson.metadata.referenceIds.map((id) =>
    requireRecord(referencesById, id, `${lesson.metadata.id} reference registry`));

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

export const structuredLessonBundles: readonly StructuredLessonBundle[] = [
  createBundle(lesson0007Raw),
  createBundle(lesson0006Raw),
];

const lessonIds = structuredLessonBundles.map((bundle) => bundle.lesson.metadata.id);
const lessonSlugs = structuredLessonBundles.map((bundle) => bundle.lesson.metadata.slug);
const lessonRoutes = structuredLessonBundles.map((bundle) => bundle.lesson.metadata.route);
for (const [label, values] of [
  ["IDs", lessonIds],
  ["slugs", lessonSlugs],
  ["routes", lessonRoutes],
] as const) {
  if (new Set(values).size !== values.length) {
    throw new Error(`structured lesson registry contains duplicate ${label}`);
  }
}

for (const assessment of assessmentRegistry) {
  const owner = structuredLessonBundles.find((bundle) =>
    bundle.lesson.metadata.id === assessment.lessonId);
  if (!owner?.lesson.metadata.assessmentIds.includes(assessment.id)) {
    throw new Error(`${assessment.id} has no exact registered lesson owner`);
  }
}

for (const reference of referenceRegistry) {
  for (const lessonId of reference.lessonIds) {
    const owner = structuredLessonBundles.find((bundle) =>
      bundle.lesson.metadata.id === lessonId);
    if (!owner?.lesson.metadata.referenceIds.includes(reference.id)) {
      throw new Error(`${reference.id} has a backlink without an exact lesson link`);
    }
  }
}

export function findStructuredLesson(slug: string): StructuredLessonBundle | undefined {
  return structuredLessonBundles.find((bundle) => bundle.lesson.metadata.slug === slug);
}
