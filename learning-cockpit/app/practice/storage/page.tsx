import Link from "next/link";
import InteractivePractice from "../../interactive-practice";

export default function StoragePracticePage() {
  return (
    <main className="cockpit-shell practice-page" id="main-content">
      <nav className="breadcrumbs" aria-label="Breadcrumb"><Link href="/">Home</Link><span>/</span><Link href="/book/linux/storage">Storage lesson</Link><span>/</span><b>Practice</b></nav>
      <header className="practice-page-heading">
        <p className="eyebrow">LESSON 01 / PRACTICE</p>
        <h1>Turn storage knowledge into operator judgment.</h1>
        <p>Practice is separate from the book so you can reread without accidentally revealing every assessment decision.</p>
      </header>
      <InteractivePractice />
    </main>
  );
}
