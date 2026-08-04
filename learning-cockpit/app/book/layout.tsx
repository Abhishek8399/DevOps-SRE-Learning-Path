import Link from "next/link";
import BookNavigation from "../book-navigation";
import ReaderContextRail from "../reader-context-rail";
import ReaderControls from "../reader-controls";

export default function BookLayout({ children }: Readonly<{ children: React.ReactNode }>) {
  return (
    <div className="book-layout">
      <BookNavigation />
      <div className="book-workspace">
        <header className="reader-topline">
          <Link href="/" className="reader-wordmark">Reliability Atlas</Link>
          <span aria-hidden="true">/</span><Link href="/book">Library</Link>
          <b>Local field edition</b>
          <ReaderControls />
        </header>
        <main className="book-reader" id="main-content">{children}</main>
      </div>
      <ReaderContextRail />
    </div>
  );
}
