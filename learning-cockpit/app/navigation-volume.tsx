"use client";

import { usePathname } from "next/navigation";
import NavigationLink from "./navigation-link";

type LessonLink = Readonly<{ canonicalId: string; number: string; route: string; title: string }>;

export default function NavigationVolume({
  number,
  route,
  title,
  lessons,
}: {
  number: string;
  route: string;
  title: string;
  lessons: readonly LessonLink[];
}) {
  const pathname = usePathname();
  const active = pathname === route || lessons.some((lesson) => lesson.route === pathname);

  return (
    <details className="nav-volume" open={active}>
      <summary>
        <span><small>Volume {number}</small><strong>{title}</strong></span>
        <b aria-hidden="true">+</b>
      </summary>
      <div className="nav-volume-lessons">
        <NavigationLink href={route}><b>{number}</b><span>Volume overview</span></NavigationLink>
        {lessons.map((lesson) => (
          <NavigationLink href={lesson.route} key={lesson.canonicalId}>
            <b>{lesson.number}</b><span>{lesson.title}</span>
          </NavigationLink>
        ))}
      </div>
    </details>
  );
}
