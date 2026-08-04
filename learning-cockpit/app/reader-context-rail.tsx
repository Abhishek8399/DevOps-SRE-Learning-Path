"use client";

import { useEffect, useMemo, useState } from "react";
import { usePathname } from "next/navigation";
import ShellToggle from "./shell-toggle";

type PageHeading = Readonly<{ id: string; text: string }>;

function noteKey(pathname: string): string {
  return `field-manual-note-v1:${pathname}`;
}

export default function ReaderContextRail() {
  const pathname = usePathname();
  const [headings, setHeadings] = useState<PageHeading[]>([]);
  const [activeId, setActiveId] = useState("");
  const [note, setNote] = useState("");
  const [announcement, setAnnouncement] = useState("");
  const storageKey = useMemo(() => noteKey(pathname), [pathname]);

  useEffect(() => {
    const candidates = [...document.querySelectorAll<HTMLElement>(
      "main h2[id],main h3[id],main section[id],main .chapter-block[id],main .depth-section[id],main .lesson-section[id],main .lesson-split[id],main .guided-lab[id]",
    )];
    const nodes = candidates.filter((node, index) => {
      if (!node.id) return false;
      return candidates.findIndex((candidate) => candidate.id === node.id) === index;
    });
    const frame = window.requestAnimationFrame(() => {
      setHeadings(nodes.map((node) => {
        const heading = node.matches("h2,h3")
          ? node
          : node.querySelector<HTMLElement>(":scope > header h2,:scope > header h3,:scope > .chapter-copy h3,:scope > .lesson-section-title h3,:scope > .lesson-prose h3,:scope > .depth-heading h3,:scope > h2,:scope > h3");
        return { id: node.id, text: heading?.textContent?.trim() || node.id.replaceAll("-", " ") };
      }));
    });
    const observer = new IntersectionObserver(
      (entries) => {
        const visible = entries.filter((entry) => entry.isIntersecting)
          .sort((left, right) => left.boundingClientRect.top - right.boundingClientRect.top);
        if (visible[0]?.target.id) setActiveId(visible[0].target.id);
      },
      { rootMargin: "-15% 0px -70% 0px" },
    );
    nodes.forEach((node) => observer.observe(node));
    return () => {
      window.cancelAnimationFrame(frame);
      observer.disconnect();
    };
  }, [pathname]);

  useEffect(() => {
    const frame = window.requestAnimationFrame(() => {
      try { setNote(window.localStorage.getItem(storageKey) || ""); } catch { setNote(""); }
    });
    return () => window.cancelAnimationFrame(frame);
  }, [storageKey]);

  const saveNote = () => {
    try {
      const trimmed = note.slice(0, 2000);
      window.localStorage.setItem(storageKey, trimmed);
      setNote(trimmed);
      setAnnouncement("Private note saved in this browser.");
    } catch {
      setAnnouncement("Browser storage is unavailable. Copy the note before leaving.");
    }
  };

  return (
    <>
      <button
        aria-label="Close context tools"
        className="context-backdrop"
        onClick={() => { document.documentElement.dataset.contextRail = "closed"; }}
        type="button"
      />
      <aside className="context-rail" aria-label="Reading context" id="reading-context">
        <header className="context-rail-header">
          <div><span>Field notes</span><strong>Reading context</strong></div>
          <ShellToggle action="close-context" className="rail-close" label="Close" />
        </header>
        {headings.length > 0 ? (
          <nav aria-label="On this page" className="on-this-page">
            <strong>On this page</strong>
            <ol>{headings.map((heading) => (
              <li key={heading.id}>
                <a aria-current={activeId === heading.id ? "location" : undefined} href={`#${heading.id}`}>{heading.text}</a>
              </li>
            ))}</ol>
          </nav>
        ) : null}
        <section className="margin-note" aria-labelledby="margin-note-title">
          <div><strong id="margin-note-title">Private margin note</strong><span>{note.length}/2000</span></div>
          <p>Stored only for this local route. Never paste secrets, credentials, employer data or production evidence.</p>
          <textarea
            aria-label="Private margin note"
            maxLength={2000}
            onChange={(event) => setNote(event.target.value)}
            placeholder="Write the idea in your own words..."
            value={note}
          />
          <button onClick={saveNote} type="button">Save note</button>
        </section>
        <a className="context-learning-link" href="/my-learning">Bookmarks and study history</a>
        <span className="sr-only" aria-live="polite">{announcement}</span>
      </aside>
    </>
  );
}
