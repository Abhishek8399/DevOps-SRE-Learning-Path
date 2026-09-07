"use client";

export default function ShellToggle({
  action,
  className,
  label,
}: {
  action: "close-navigation" | "close-context";
  className?: string;
  label: string;
}) {
  const close = () => {
    const navigation = action === "close-navigation";
    const datasetKey = navigation ? "navigation" : "contextRail";
    const storageKey = navigation ? "field-manual-navigation" : "field-manual-context-rail";
    const controlledId = navigation ? "book-navigation" : "reading-context";
    document.documentElement.dataset[datasetKey] = "closed";
    try { window.localStorage.setItem(storageKey, "closed"); } catch { /* The in-memory close still succeeds. */ }
    window.requestAnimationFrame(() => {
      document.querySelector<HTMLButtonElement>(`button[aria-controls="${controlledId}"]`)?.focus();
    });
  };
  return <button aria-label={label} className={className} onClick={close} type="button">{label}</button>;
}
