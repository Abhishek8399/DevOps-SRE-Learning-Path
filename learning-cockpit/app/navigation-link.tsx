"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import type { ReactNode } from "react";

export default function NavigationLink({
  children,
  className,
  href,
}: {
  children: ReactNode;
  className?: string;
  href: string;
}) {
  const pathname = usePathname();
  return (
    <Link
      aria-current={pathname === href ? "page" : undefined}
      className={className}
      href={href}
    >
      {children}
    </Link>
  );
}
