import Link from "next/link";
import InterviewMockRunner from "../../interview-mock-runner";
import InteractivePractice from "../../interactive-practice";

export default function InterviewPracticePage() {
  return (
    <main className="cockpit-shell practice-page" id="main-content">
      <nav className="breadcrumbs" aria-label="Breadcrumb"><Link href="/">Home</Link><span>/</span><b>Interview practice</b></nav>
      <header className="practice-page-heading">
        <p className="eyebrow">INTERVIEW PRACTICE / OPERATING JUDGMENT</p>
        <h1>Explain the system before you reach for the command.</h1>
        <p>Use the four modes to recall, teach, diagnose, and defend an operational decision. Reading an answer is not evidence of interview readiness; speak first, then compare your reasoning.</p>
      </header>
      <InterviewMockRunner />
      <InteractivePractice />
    </main>
  );
}
