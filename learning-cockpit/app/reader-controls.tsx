"use client";

import { useEffect, useState } from "react";

const sizes = ["compact", "comfortable", "large"] as const;
type ReaderSize = (typeof sizes)[number];

function storedSize(): ReaderSize {
  const current = document.documentElement.dataset.readingSize;
  return sizes.includes(current as ReaderSize) ? current as ReaderSize : "comfortable";
}

function savePreference(key: string, value: string) {
  try {
    window.localStorage.setItem(key, value);
  } catch {
    // Display preferences remain usable even when storage is disabled.
  }
}

export default function ReaderControls() {
  const [progress, setProgress] = useState(0);
  const [announcement, setAnnouncement] = useState("");

  useEffect(() => {
    const updateProgress = () => {
      const scrollable = document.documentElement.scrollHeight - window.innerHeight;
      setProgress(scrollable > 0 ? Math.min(100, Math.round((window.scrollY / scrollable) * 100)) : 100);
    };
    const frame = window.requestAnimationFrame(updateProgress);
    window.addEventListener("scroll", updateProgress, { passive: true });
    window.addEventListener("resize", updateProgress);
    return () => {
      window.cancelAnimationFrame(frame);
      window.removeEventListener("scroll", updateProgress);
      window.removeEventListener("resize", updateProgress);
    };
  }, []);

  const changeSize = (direction: -1 | 1) => {
    const current = storedSize();
    const nextIndex = Math.max(0, Math.min(sizes.length - 1, sizes.indexOf(current) + direction));
    const next = sizes[nextIndex];
    document.documentElement.dataset.readingSize = next;
    savePreference("field-manual-reading-size", next);
    setAnnouncement(`Reading size: ${next}`);
  };

  const toggleTheme = () => {
    const next = document.documentElement.dataset.readerTheme === "night" ? "paper" : "night";
    document.documentElement.dataset.readerTheme = next;
    savePreference("field-manual-theme", next);
    setAnnouncement(`${next === "night" ? "Night" : "Paper"} reading mode enabled`);
  };

  return (
    <>
      <div
        aria-label="Lesson reading progress"
        aria-valuemax={100}
        aria-valuemin={0}
        aria-valuenow={progress}
        className="reading-progress"
        role="progressbar"
      >
        <span style={{ width: `${progress}%` }} />
      </div>
      <div className="reader-controls" role="group" aria-label="Reader appearance">
        <span className="reader-controls-label">READING</span>
        <button type="button" onClick={() => changeSize(-1)} aria-label="Decrease reading text size" title="Smaller text">A-</button>
        <button type="button" onClick={() => changeSize(1)} aria-label="Increase reading text size" title="Larger text">A+</button>
        <button type="button" onClick={toggleTheme} aria-label="Toggle paper and night reading mode" title="Paper or night mode">Day / Night</button>
        <button type="button" onClick={() => window.print()} aria-label="Print this lesson" title="Print this lesson">Print</button>
      </div>
      <span className="sr-only" aria-live="polite">{announcement}</span>
    </>
  );
}
