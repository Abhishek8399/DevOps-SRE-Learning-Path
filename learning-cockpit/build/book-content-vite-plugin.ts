import { readFile, readdir } from "node:fs/promises";
import { resolve } from "node:path";
import type { Plugin } from "vite";
import { parseStructuredLesson } from "../app/lessons/structured-lesson-parser.ts";
import { generatedLessonPaths as lessonPaths } from "./generated-lesson-paths.ts";

const VIRTUAL_PREFIX = "virtual:book-lesson/";
const RESOLVED_PREFIX = `\0${VIRTUAL_PREFIX}`;
const CAREER_MODULE = "virtual:career-primers";
const RESOLVED_CAREER_MODULE = `\0${CAREER_MODULE}`;
const DRAFT_MODULE = "virtual:staged-drafts";
const RESOLVED_DRAFT_MODULE = `\0${DRAFT_MODULE}`;

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
      if (id === CAREER_MODULE) return RESOLVED_CAREER_MODULE;
      if (id === DRAFT_MODULE) return RESOLVED_DRAFT_MODULE;
      if (!id.startsWith(VIRTUAL_PREFIX)) return null;
      const lessonId = id.slice(VIRTUAL_PREFIX.length);
      if (!isRegisteredLessonId(lessonId)) {
        throw new Error(`unregistered virtual lesson module: ${lessonId}`);
      }
      return `${RESOLVED_PREFIX}${lessonId}`;
    },
    async load(id) {
      if (id === RESOLVED_CAREER_MODULE) {
        const careerDirectory = resolve(repositoryRoot, "career");
        const files = (await readdir(careerDirectory))
          .filter((file) => /^[a-z0-9-]+-primer\.md$/.test(file))
          .sort();
        const primers = await Promise.all(files.map(async (file) => {
          const sourcePath = resolve(careerDirectory, file);
          this.addWatchFile(sourcePath);
          const source = await readFile(sourcePath, "utf8");
          const title = source.match(/^#\s+(.+)$/m)?.[1]?.trim();
          if (!title) throw new Error(`career primer is missing an H1: ${file}`);
          return { slug: file.replace(/\.md$/, ""), title, source };
        }));
        return { code: `export const generatedCareerPrimerSources = ${JSON.stringify(primers)};`, map: null };
      }
      if (id === RESOLVED_DRAFT_MODULE) {
        const draftsDirectory = resolve(repositoryRoot, "drafts");
        const candidateDirectories = (await readdir(draftsDirectory, { withFileTypes: true }))
          .filter((entry) => entry.isDirectory()
            && /^LES-\d{4}-[a-z0-9-]+$/.test(entry.name))
          .sort((left, right) => left.name.localeCompare(right.name));
        const directories = (await Promise.all(candidateDirectories.map(async (entry) => {
          const files = await readdir(resolve(draftsDirectory, entry.name));
          return files.includes("lesson.md") ? entry : null;
        }))).filter((entry): entry is NonNullable<typeof entry> => entry !== null);
        const referencesById = new Map<string, unknown>();
        const loadReferenceDirectory = async (directory: string) => {
          let files: string[];
          try {
            files = await readdir(directory);
          } catch (error) {
            if (error && typeof error === "object" && "code" in error && error.code === "ENOENT") return;
            throw error;
          }
          for (const file of files.filter((name) => /^REF-\d{4}\.json$/.test(name)).sort()) {
            const referencePath = resolve(directory, file);
            const value: unknown = JSON.parse(await readFile(referencePath, "utf8"));
            const id = value && typeof value === "object" && "id" in value ? value.id : undefined;
            if (typeof id !== "string" || referencesById.has(id)) {
              throw new Error(`staged reference identity is invalid or duplicated: ${file}`);
            }
            this.addWatchFile(referencePath);
            referencesById.set(id, value);
          }
        };
        await loadReferenceDirectory(resolve(repositoryRoot, "book", "references"));
        for (const entry of directories) {
          await loadReferenceDirectory(resolve(draftsDirectory, entry.name, "support", "references"));
        }
        const drafts = await Promise.all(directories.map(async (entry) => {
          const sourcePath = resolve(draftsDirectory, entry.name, "lesson.md");
          const assessmentDirectory = resolve(draftsDirectory, entry.name, "support", "assessments");
          this.addWatchFile(sourcePath);
          const source = await readFile(sourcePath, "utf8");
          const assessmentFiles = (await readdir(assessmentDirectory))
            .filter((file) => /^ASM-\d{4}\.json$/.test(file))
            .sort();
          const assessments = await Promise.all(assessmentFiles.map(async (file) => {
            const assessmentPath = resolve(assessmentDirectory, file);
            this.addWatchFile(assessmentPath);
            return JSON.parse(await readFile(assessmentPath, "utf8"));
          }));
          const referenceIds = parseStructuredLesson(source).metadata.referenceIds;
          const references = referenceIds.map((referenceId) => {
            const reference = referencesById.get(referenceId);
            if (reference === undefined) throw new Error(`${entry.name} declares missing reference ${referenceId}`);
            return reference;
          });
          return { slug: entry.name, source, assessments, references };
        }));
        return { code: `export const generatedStagedDraftSources = ${JSON.stringify(drafts)};`, map: null };
      }
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
