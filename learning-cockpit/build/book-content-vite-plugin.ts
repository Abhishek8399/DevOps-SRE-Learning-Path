import { readFile } from "node:fs/promises";
import { resolve } from "node:path";
import type { Plugin } from "vite";

const VIRTUAL_PREFIX = "virtual:book-lesson/";
const RESOLVED_PREFIX = `\0${VIRTUAL_PREFIX}`;

const lessonPaths = {
  "LES-0006": [
    "book",
    "volumes",
    "01-linux-systems",
    "LES-0006-boot-kernel-systemd-journal",
    "lesson.md",
  ],
  "LES-0007": [
    "book",
    "volumes",
    "00-start-safely",
    "LES-0007-systems-thinking",
    "lesson.md",
  ],
  "LES-0008": [
    "book",
    "volumes",
    "00-start-safely",
    "LES-0008-evidence-driven-troubleshooting",
    "lesson.md",
  ],
} as const;

type RegisteredLessonId = keyof typeof lessonPaths;

function isRegisteredLessonId(value: string): value is RegisteredLessonId {
  return Object.hasOwn(lessonPaths, value);
}

// Embeds canonical Markdown at build/dev time without exposing parent-directory
// file IDs to the Cloudflare module runner. The registry is intentionally exact.
export function bookContent(): Plugin {
  let repositoryRoot = resolve(process.cwd(), "..");

  return {
    name: "book-content",
    enforce: "pre",
    configResolved(config) {
      repositoryRoot = resolve(config.root, "..");
    },
    resolveId(id) {
      if (!id.startsWith(VIRTUAL_PREFIX)) return null;
      const lessonId = id.slice(VIRTUAL_PREFIX.length);
      if (!isRegisteredLessonId(lessonId)) {
        throw new Error(`unregistered virtual lesson module: ${lessonId}`);
      }
      return `${RESOLVED_PREFIX}${lessonId}`;
    },
    async load(id) {
      if (!id.startsWith(RESOLVED_PREFIX)) return null;
      const lessonId = id.slice(RESOLVED_PREFIX.length);
      if (!isRegisteredLessonId(lessonId)) {
        throw new Error(`unregistered resolved lesson module: ${lessonId}`);
      }
      const sourcePath = resolve(repositoryRoot, ...lessonPaths[lessonId]);
      this.addWatchFile(sourcePath);
      const source = await readFile(sourcePath, "utf8");
      return {
        code: `export default ${JSON.stringify(source)};`,
        map: null,
      };
    },
  };
}
