"use client";

import { useEffect, useRef, useState } from "react";

const themes = ["paper", "night", "sepia"] as const;
const sizes = ["compact", "comfortable", "large"] as const;
const leadings = ["tight", "relaxed", "airy"] as const;
const widths = ["narrow", "standard", "wide"] as const;

type Theme = (typeof themes)[number];
type ReaderSize = (typeof sizes)[number];
type ReaderLeading = (typeof leadings)[number];
type ReaderWidth = (typeof widths)[number];

function store(key: string, value: string) {
  try { window.localStorage.setItem(key, value); } catch { /* Preferences remain usable in memory. */ }
}

function setDataset(name: string, value: string, storageKey: string) {
  document.documentElement.dataset[name] = value;
  store(storageKey, value);
}

export default function ReaderControls() {
  const [progress, setProgress] = useState(0);
  const [theme, setTheme] = useState<Theme>("paper");
  const [size, setSize] = useState<ReaderSize>("comfortable");
  const [leading, setLeading] = useState<ReaderLeading>("relaxed");
  const [width, setWidth] = useState<ReaderWidth>("standard");
  const [wrapped, setWrapped] = useState(false);
  const [focused, setFocused] = useState(false);
  const [navigationOpen, setNavigationOpen] = useState(true);
  const [contextOpen, setContextOpen] = useState(true);
  const [announcement, setAnnouncement] = useState("");
  const navigationTrigger = useRef<HTMLButtonElement>(null);
  const contextTrigger = useRef<HTMLButtonElement>(null);

  useEffect(() => {
    const root = document.documentElement;
    const syncWrapped = () => setWrapped(root.dataset.codeWrap === "wrap");
    const frame = window.requestAnimationFrame(() => {
      setTheme(themes.includes(root.dataset.readerTheme as Theme) ? root.dataset.readerTheme as Theme : "paper");
      setSize(sizes.includes(root.dataset.readingSize as ReaderSize) ? root.dataset.readingSize as ReaderSize : "comfortable");
      setLeading(leadings.includes(root.dataset.readingLeading as ReaderLeading) ? root.dataset.readingLeading as ReaderLeading : "relaxed");
      setWidth(widths.includes(root.dataset.readingWidth as ReaderWidth) ? root.dataset.readingWidth as ReaderWidth : "standard");
      syncWrapped();
      setFocused(root.dataset.readingFocus === "on");
      setNavigationOpen(root.dataset.navigation !== "closed");
      setContextOpen(root.dataset.contextRail !== "closed");
    });
    window.addEventListener("field-manual-code-wrap", syncWrapped);
    return () => {
      window.cancelAnimationFrame(frame);
      window.removeEventListener("field-manual-code-wrap", syncWrapped);
    };
  }, []);

  useEffect(() => {
    const updateProgress = () => {
      const scrollable = document.documentElement.scrollHeight - window.innerHeight;
      setProgress(scrollable > 0 ? Math.min(100, Math.round((window.scrollY / scrollable) * 100)) : 100);
    };
    const closeOverlays = (event: KeyboardEvent) => {
      if (event.key !== "Escape") return;
      const navigationWasOpen = document.documentElement.dataset.navigation !== "closed";
      const contextWasOpen = document.documentElement.dataset.contextRail !== "closed";
      document.documentElement.dataset.navigation = "closed";
      document.documentElement.dataset.contextRail = "closed";
      setNavigationOpen(false);
      setContextOpen(false);
      if (contextWasOpen) contextTrigger.current?.focus();
      else if (navigationWasOpen) navigationTrigger.current?.focus();
      setAnnouncement("Reader drawers closed.");
    };
    const root = document.documentElement;
    const observeShell = new MutationObserver(() => {
      setNavigationOpen(root.dataset.navigation !== "closed");
      setContextOpen(root.dataset.contextRail !== "closed");
    });
    observeShell.observe(root, { attributes: true, attributeFilter: ["data-navigation", "data-context-rail"] });
    const frame = window.requestAnimationFrame(updateProgress);
    window.addEventListener("scroll", updateProgress, { passive: true });
    window.addEventListener("resize", updateProgress);
    window.addEventListener("keydown", closeOverlays);
    return () => {
      window.cancelAnimationFrame(frame);
      window.removeEventListener("scroll", updateProgress);
      window.removeEventListener("resize", updateProgress);
      window.removeEventListener("keydown", closeOverlays);
      observeShell.disconnect();
    };
  }, []);

  useEffect(() => {
    const contextDrawer = contextOpen && window.matchMedia("(max-width: 1180px)").matches;
    const navigationDrawer = navigationOpen && window.matchMedia("(max-width: 980px)").matches;
    const container = contextDrawer
      ? document.querySelector<HTMLElement>("#reading-context")
      : navigationDrawer
        ? document.querySelector<HTMLElement>("#book-navigation")
        : null;
    if (!container) return;
    const selector = 'a[href],button:not([disabled]),summary,textarea,select,input,[tabindex]:not([tabindex="-1"])';
    const frame = window.requestAnimationFrame(() => {
      container.querySelector<HTMLElement>(selector)?.focus();
    });
    const trap = (event: KeyboardEvent) => {
      if (event.key !== "Tab") return;
      const items = [...container.querySelectorAll<HTMLElement>(selector)].filter((item) => item.offsetParent !== null);
      if (!items.length) return;
      const first = items[0];
      const last = items[items.length - 1];
      if (event.shiftKey && document.activeElement === first) {
        event.preventDefault();
        last.focus();
      } else if (!event.shiftKey && document.activeElement === last) {
        event.preventDefault();
        first.focus();
      }
    };
    window.addEventListener("keydown", trap);
    return () => {
      window.cancelAnimationFrame(frame);
      window.removeEventListener("keydown", trap);
    };
  }, [contextOpen, navigationOpen]);

  const chooseTheme = (value: Theme) => {
    setTheme(value);
    setDataset("readerTheme", value, "field-manual-theme");
    setAnnouncement(`${value} reading theme enabled.`);
  };
  const chooseSize = (value: ReaderSize) => {
    setSize(value);
    setDataset("readingSize", value, "field-manual-reading-size");
    setAnnouncement(`${value} text size enabled.`);
  };
  const chooseLeading = (value: ReaderLeading) => {
    setLeading(value);
    setDataset("readingLeading", value, "field-manual-reading-leading");
    setAnnouncement(`${value} line spacing enabled.`);
  };
  const chooseWidth = (value: ReaderWidth) => {
    setWidth(value);
    setDataset("readingWidth", value, "field-manual-reading-width");
    setAnnouncement(`${value} reading width enabled.`);
  };
  const toggleWrap = () => {
    const next = !wrapped;
    setWrapped(next);
    setDataset("codeWrap", next ? "wrap" : "scroll", "field-manual-code-wrap");
    window.dispatchEvent(new Event("field-manual-code-wrap"));
    setAnnouncement(`Code lines now ${next ? "wrap" : "scroll horizontally"}.`);
  };
  const toggleFocus = () => {
    const next = !focused;
    setFocused(next);
    setDataset("readingFocus", next ? "on" : "off", "field-manual-reading-focus");
    setAnnouncement(`Distraction-free reading ${next ? "enabled" : "disabled"}.`);
  };
  const toggleRail = (name: "navigation" | "contextRail") => {
    const root = document.documentElement;
    const current = root.dataset[name] || "open";
    const next = current === "closed" ? "open" : "closed";
    root.dataset[name] = next;
    store(name === "navigation" ? "field-manual-navigation" : "field-manual-context-rail", next);
    if (name === "navigation") setNavigationOpen(next === "open");
    else setContextOpen(next === "open");
    setAnnouncement(`${name === "navigation" ? "Book navigation" : "Context rail"} ${next}.`);
  };

  return (
    <>
      <div aria-label="Reading progress" aria-valuemax={100} aria-valuemin={0} aria-valuenow={progress} className="reading-progress" role="progressbar">
        <span style={{ width: `${progress}%` }} />
      </div>
      <div className="reader-toolbar" role="toolbar" aria-label="Reader tools">
        <button aria-controls="book-navigation" aria-expanded={navigationOpen} aria-label="Toggle book navigation" onClick={() => toggleRail("navigation")} ref={navigationTrigger} type="button"><span aria-hidden="true">Contents</span></button>
        <button aria-controls="reading-context" aria-expanded={contextOpen} aria-label="Toggle page context" onClick={() => toggleRail("contextRail")} ref={contextTrigger} type="button"><span aria-hidden="true">On this page</span></button>
        <button aria-pressed={focused} onClick={toggleFocus} type="button">Focus</button>
        <details className="reader-settings">
          <summary>Appearance</summary>
          <div className="reader-settings-popover">
            <fieldset><legend>Theme</legend><div>{themes.map((value) => <button aria-pressed={theme === value} key={value} onClick={() => chooseTheme(value)} type="button">{value}</button>)}</div></fieldset>
            <fieldset><legend>Text size</legend><div>{sizes.map((value) => <button aria-pressed={size === value} key={value} onClick={() => chooseSize(value)} type="button">{value}</button>)}</div></fieldset>
            <fieldset><legend>Line spacing</legend><div>{leadings.map((value) => <button aria-pressed={leading === value} key={value} onClick={() => chooseLeading(value)} type="button">{value}</button>)}</div></fieldset>
            <fieldset><legend>Reading width</legend><div>{widths.map((value) => <button aria-pressed={width === value} key={value} onClick={() => chooseWidth(value)} type="button">{value}</button>)}</div></fieldset>
            <button aria-pressed={wrapped} className="wrap-setting" onClick={toggleWrap} type="button">Wrap long code lines</button>
          </div>
        </details>
        <button onClick={() => window.print()} type="button">Print</button>
        <span className="reader-percent" aria-hidden="true">{progress}%</span>
      </div>
      <span className="sr-only" aria-live="polite">{announcement}</span>
    </>
  );
}
