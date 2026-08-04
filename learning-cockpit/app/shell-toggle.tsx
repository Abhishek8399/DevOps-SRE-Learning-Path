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
    if (action === "close-navigation") document.documentElement.dataset.navigation = "closed";
    else document.documentElement.dataset.contextRail = "closed";
  };
  return <button aria-label={label} className={className} onClick={close} type="button">{label}</button>;
}
