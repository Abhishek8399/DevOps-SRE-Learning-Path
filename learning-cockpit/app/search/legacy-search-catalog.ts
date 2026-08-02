import { commandDecoders } from "../lessons/command-decoders.ts";
import {
  foundationLessons,
  type FoundationLessonId,
} from "../lessons/foundation-lessons.ts";
import {
  lessonGlossaries,
  type LessonGlossaryId,
} from "../lessons/lesson-glossaries.ts";
import { getReaderVolume } from "../lessons/reader-catalog-core.ts";
import type { SearchDocument } from "./search-index.ts";

const linuxVolume = getReaderVolume("01-linux-systems");

const canonicalIds: Readonly<Record<FoundationLessonId, readonly string[]>> = {
  "processes-signals-systemd": ["LES-0002", "02", "V01-L02", "LNX-002"],
  "cpu-memory-pressure": ["LES-0003", "03", "V01-L03", "LNX-003"],
  "network-request-path": ["LES-0004", "04", "V01-L04", "NET-003", "NET-004", "NET-005", "NET-006"],
  "identity-permissions": ["LES-0005", "05", "V01-L05", "LNX-004"],
};

const incidentAliases: Partial<Record<FoundationLessonId, readonly string[]>> = {
  "cpu-memory-pressure": ["Container exit 137 after SIGKILL"],
};

function unique(values: readonly string[]): string[] {
  return [...new Set(values.filter((value) => value.trim().length > 0))];
}

function glossaryTerms(lessonId: LessonGlossaryId): string[] {
  return lessonGlossaries[lessonId].map((entry) => entry.term);
}

function decoderCommands(lessonId: LessonGlossaryId): string[] {
  return commandDecoders[lessonId].map((decoder) => decoder.command);
}

const storageDocument: SearchDocument = {
  id: "storage",
  number: "01",
  volumeNumber: linuxVolume.volumeNumber,
  volumeTitle: linuxVolume.volumeTitle,
  title: "Linux storage: blocks, inodes, and ENOSPC",
  subtitle:
    "Map the exact path, identify the exhausted allocation, and recover without blind deletion.",
  href: "/book/linux/storage",
  fields: [
    {
      category: "Lesson ID",
      values: ["storage", "LES-0001", "01", "V01-L01", "LNX-001"],
      weight: 16,
    },
    {
      category: "Title",
      values: [
        "Linux storage: blocks, inodes, and ENOSPC",
        "Storage and ENOSPC",
      ],
      weight: 14,
    },
    {
      category: "Incident signal",
      values: [
        "No space left on device",
        "ENOSPC while the filesystem still has free bytes",
        "An upload cannot create a new file",
        "df and du report different usage",
        "A deleted log still consumes space",
        "A user, group, project, container, or tmpfs quota is exhausted",
      ],
      weight: 11,
    },
    {
      category: "Command",
      values: unique([
        "findmnt -T <path>",
        "df -hT <path>",
        "df -i <path>",
        "du -xah <path>",
        "lsof +L1",
        ...decoderCommands("storage"),
      ]),
      weight: 9,
    },
    {
      category: "Term",
      values: glossaryTerms("storage"),
      weight: 8,
    },
    {
      category: "Lesson guidance",
      values: [
        "Blocks and inodes are independent filesystem capacities.",
        "Always inspect the exact failing path because mounts and namespaces change which filesystem owns it.",
        "Identify the producer, retention policy, quota, and runtime limit before deleting or expanding anything.",
        "Deleted-open files keep their allocation until the final file descriptor closes.",
      ],
      weight: 4,
    },
  ],
};

function createFoundationDocument(
  lesson: (typeof foundationLessons)[number],
): SearchDocument {
  const lessonId = lesson.id;

  return {
    id: lessonId,
    number: lesson.number,
    title: lesson.title,
    volumeNumber: linuxVolume.volumeNumber,
    volumeTitle: linuxVolume.volumeTitle,
    subtitle: lesson.subtitle,
    href: `/book/linux/${lessonId}`,
    fields: [
      {
        category: "Lesson ID",
        values: [lessonId, ...canonicalIds[lessonId]],
        weight: 16,
      },
      {
        category: "Title",
        values: [lesson.title, lesson.subtitle],
        weight: 14,
      },
      {
        category: "Incident signal",
        values: [
          lesson.incident.signal,
          lesson.incident.firstThought,
          lesson.incident.trap,
          ...(incidentAliases[lessonId] ?? []),
        ],
        weight: 11,
      },
      {
        category: "Command",
        values: unique([
          ...lesson.commands.map((command) => command.command),
          ...decoderCommands(lessonId),
        ]),
        weight: 9,
      },
      {
        category: "Term",
        values: unique([
          ...lesson.mechanisms.map((mechanism) => mechanism.term),
          ...glossaryTerms(lessonId),
        ]),
        weight: 8,
      },
      {
        category: "Lesson guidance",
        values: [
          lesson.mentalModel,
          lesson.memoryRule,
          lesson.incident.safePath,
          lesson.interviewPrompt,
          ...lesson.checkpoint,
          ...lesson.mechanisms.map((mechanism) => mechanism.explanation),
        ],
        weight: 4,
      },
    ],
  };
}

export const legacySearchDocuments: readonly SearchDocument[] = [
  storageDocument,
  ...foundationLessons.map(createFoundationDocument),
];
