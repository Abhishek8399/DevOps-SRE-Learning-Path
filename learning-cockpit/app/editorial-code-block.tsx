"use client";

import { useEffect, useState } from "react";
import CopyCommand from "./copy-command";

export default function EditorialCodeBlock({
  language,
  value,
  diagram = false,
}: {
  language: string;
  value: string;
  diagram?: boolean;
}) {
  const [wrapped, setWrapped] = useState(false);
  const lines = value.split("\n");
  const copyable = ["bash", "sh", "shell", "powershell", "python", "yaml", "json", "hcl"].includes(language);
  const role = diagram ? "System figure" : language ? "Code example" : "Expected output";

  useEffect(() => {
    const frame = window.requestAnimationFrame(() => {
      setWrapped(document.documentElement.dataset.codeWrap === "wrap");
    });
    return () => window.cancelAnimationFrame(frame);
  }, []);

  const toggleWrap = () => {
    const next = !wrapped;
    setWrapped(next);
    document.documentElement.dataset.codeWrap = next ? "wrap" : "scroll";
    try { window.localStorage.setItem("field-manual-code-wrap", next ? "wrap" : "scroll"); } catch { /* Local preference only. */ }
  };

  return (
    <figure className={`editorial-code ${diagram ? "editorial-diagram" : ""}`}>
      <figcaption>
        <span><b>{role}</b><small>{diagram ? "text diagram" : language || "output"}</small></span>
        <span className="editorial-code-actions">
          {!diagram ? <button aria-pressed={wrapped} onClick={toggleWrap} type="button">{wrapped ? "Scroll lines" : "Wrap lines"}</button> : null}
          {copyable ? <CopyCommand text={value} /> : null}
        </span>
      </figcaption>
      <pre><code>{lines.map((line, index) => <span className="code-line" key={`${index}-${line.slice(0,12)}`}><i aria-hidden="true">{index + 1}</i><span>{line || " "}</span></span>)}</code></pre>
    </figure>
  );
}
