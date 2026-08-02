import {
  generatedAssessmentValues,
  generatedLessonSources,
  generatedReferenceValues,
} from "./generated-structured-records";
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

const assessmentRegistry: readonly StructuredAssessment[] = generatedAssessmentValues.map(parseStructuredAssessment);

const referenceRegistry: readonly StructuredReference[] = generatedReferenceValues.map(parseStructuredReference);

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

export const structuredLessonBundles: readonly StructuredLessonBundle[] =
  generatedLessonSources.map(createBundle);

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
