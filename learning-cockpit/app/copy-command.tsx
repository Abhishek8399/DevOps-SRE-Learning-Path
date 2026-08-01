"use client";

import { useEffect, useRef, useState } from "react";
import styles from "./copy-command.module.css";

type CopyStatus = "idle" | "copied" | "error";

export default function CopyCommand({ text }: { text: string }) {
  const [status, setStatus] = useState<CopyStatus>("idle");
  const resetTimer = useRef<number | null>(null);

  useEffect(() => () => {
    if (resetTimer.current !== null) window.clearTimeout(resetTimer.current);
  }, []);

  const copy = async () => {
    if (resetTimer.current !== null) window.clearTimeout(resetTimer.current);
    try {
      if (!navigator.clipboard?.writeText) throw new Error("Clipboard API unavailable");
      await navigator.clipboard.writeText(text);
      setStatus("copied");
    } catch {
      setStatus("error");
    }
    resetTimer.current = window.setTimeout(() => setStatus("idle"), 2400);
  };

  const label = status === "copied"
    ? "Copied"
    : status === "error"
      ? "Select and copy manually"
      : "Copy command";

  return (
    <button
      className={styles.button}
      onClick={copy}
      title={label}
      aria-label={status === "idle" ? "Copy this command" : label}
      type="button"
    >
      <span aria-live="polite">{label}</span>
    </button>
  );
}
