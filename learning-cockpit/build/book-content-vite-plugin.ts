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
  "LES-0009": [
    "book",
    "volumes",
    "03-engineering-delivery",
    "LES-0009-safe-local-workbench",
    "lesson.md",
  ],
  "LES-0010": [
    "book",
    "volumes",
    "01-linux-systems",
    "LES-0010-block-io-storage-performance",
    "lesson.md",
  ],
  "LES-0011": [
    "book",
    "volumes",
    "01-linux-systems",
    "LES-0011-namespaces-cgroups-isolation",
    "lesson.md",
  ],
  "LES-0012": [
    "book",
    "volumes",
    "02-connectivity",
    "LES-0012-ethernet-ip-cidr-routing-nat",
    "lesson.md",
  ],
  "LES-0013": [
    "book",
    "volumes",
    "02-connectivity",
    "LES-0013-tcp-udp-sockets-exhaustion",
    "lesson.md",
  ],
  "LES-0014": [
    "book",
    "volumes",
    "02-connectivity",
    "LES-0014-dns-service-discovery",
    "lesson.md",
  ],
  "LES-0015": [
    "book",
    "volumes",
    "02-connectivity",
    "LES-0015-http-proxies-load-balancing",
    "lesson.md",
  ],
  "LES-0016": [
    "book",
    "volumes",
    "02-connectivity",
    "LES-0016-tls-pki-mtls-rotation",
    "lesson.md",
  ],
  "LES-0017": [
    "book",
    "volumes",
    "03-engineering-delivery",
    "LES-0017-bash-safe-automation",
    "lesson.md",
  ],
  "LES-0018": [
    "book",
    "volumes",
    "03-engineering-delivery",
    "LES-0018-python-operational-automation",
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
