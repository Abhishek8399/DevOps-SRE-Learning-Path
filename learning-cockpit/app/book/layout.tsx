import Link from "next/link";
import BookNavigation from "../book-navigation";

export default function BookLayout({ children }: Readonly<{ children: React.ReactNode }>) {
  return (
    <div className="book-layout">
      <BookNavigation />
      <main className="book-reader" id="main-content">
        <div className="reader-topline">
          <Link href="/">Home</Link><span>/</span><Link href="/book">Library</Link>
          <b>Local Ubuntu-first edition</b>
        </div>
        {children}
      </main>
    </div>
  );
}
