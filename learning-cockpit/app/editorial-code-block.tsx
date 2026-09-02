"use client";

import { useEffect, useState } from "react";
import CopyCommand from "./copy-command";
import type { MarkdownCodeRole } from "./lessons/structured-lesson-parser";

const SHELL_LANGUAGES = new Set(["bash", "sh", "shell", "powershell"]);
const CONFIGURATION_LANGUAGES = new Set(["dockerfile", "groovy", "hcl", "json", "yaml", "yml"]);

function inferredRole(language: string, diagram: boolean): MarkdownCodeRole {
  if (diagram || language === "text") return "diagram";
  if (!language) return "output";
  if (SHELL_LANGUAGES.has(language)) return "command";
  if (language === "console") return "transcript";
  if (CONFIGURATION_LANGUAGES.has(language)) return "configuration";
  return "source";
}

const ROLE_LABELS: Readonly<Record<MarkdownCodeRole, string>> = {
  command: "Command",
  configuration: "Configuration",
  diagram: "System figure",
  output: "Expected output",
  source: "Source code",
  transcript: "Terminal transcript",
};

export default function EditorialCodeBlock({
  language,
  value,
  diagram = false,
  role,
  filename,
  lineNumbers,
}: {
  language: string;
  value: string;
  diagram?: boolean;
  role?: MarkdownCodeRole;
  filename?: string;
  lineNumbers?: boolean;
}) {
  const [wrapped, setWrapped] = useState(false);
  const lines = value.split("\n");
  const resolvedRole = role ?? inferredRole(language, diagram);
  const resolvedDiagram = resolvedRole === "diagram";
  const showLineNumbers = lineNumbers ?? !resolvedDiagram;
  const descriptor = filename ?? (resolvedDiagram ? "text diagram" : language || "plain text");

  useEffect(() => {
    const syncWrapped = () => {
      setWrapped(document.documentElement.dataset.codeWrap === "wrap");
    };
    const frame = window.requestAnimationFrame(() => {
      syncWrapped();
    });
    window.addEventListener("field-manual-code-wrap", syncWrapped);
    return () => {
      window.cancelAnimationFrame(frame);
      window.removeEventListener("field-manual-code-wrap", syncWrapped);
    };
  }, []);

  const toggleWrap = () => {
    const next = !wrapped;
    setWrapped(next);
    document.documentElement.dataset.codeWrap = next ? "wrap" : "scroll";
    try { window.localStorage.setItem("field-manual-code-wrap", next ? "wrap" : "scroll"); } catch { /* Local preference only. */ }
    window.dispatchEvent(new Event("field-manual-code-wrap"));
  };

  return (
    <figure className={`editorial-code ${resolvedDiagram ? "editorial-diagram" : ""} ${showLineNumbers ? "" : "editorial-code-no-lines"}`}>
      <figcaption>
        <span><b>{ROLE_LABELS[resolvedRole]}</b><small>{descriptor}</small></span>
        <span className="editorial-code-actions">
          {!resolvedDiagram ? <button aria-pressed={wrapped} onClick={toggleWrap} type="button">{wrapped ? "Scroll all lines" : "Wrap all lines"}</button> : null}
          {!resolvedDiagram ? <CopyCommand text={value} /> : null}
        </span>
      </figcaption>
      <pre><code>{lines.map((line, index) => <span className="code-line" key={`${index}-${line.slice(0,12)}`}>{showLineNumbers ? <i aria-hidden="true">{index + 1}</i> : null}<span>{line || " "}</span></span>)}</code></pre>
    </figure>
  );
}
