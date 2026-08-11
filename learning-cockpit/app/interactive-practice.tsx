"use client";

import { useEffect, useState } from "react";

type Mode = "incident" | "recall" | "teach" | "interview";

const modes: Array<{ id: Mode; label: string; detail: string }> = [
  { id: "incident", label: "Break the system", detail: "Choose the next safe move" },
  { id: "recall", label: "Recall the system", detail: "Flip compact memory cards" },
  { id: "teach", label: "Teach the system", detail: "Explain it in your own words" },
  { id: "interview", label: "Defend the system", detail: "Answer under interview pressure" },
];

const flashcards = [
  { q: "What does ENOSPC prove?", a: "A required storage allocation failed. It does not prove the whole disk is out of bytes." },
  { q: "What does df -hT tell you?", a: "Filesystem type, backing mount, and data-block capacity for the exact path." },
  { q: "What does df -i tell you?", a: "Inode capacity: how many filesystem-object records are used and available." },
  { q: "What frees many inodes?", a: "Removing many approved filesystem objects, after identifying their producer and retention policy." },
];

const incidentChoices = [
  { label: "Restart the API", tone: "unsafe", feedback: "A restart changes state, loses evidence, and does not create inodes." },
  { label: "Run df -i on the exact path", tone: "correct", feedback: "Correct. It tests the independent resource required to create another file." },
  { label: "Delete the largest file", tone: "unsafe", feedback: "One large file usually frees one inode. You have not proved it is safe to delete." },
];

const interviewQuestions = [
  {
    role: "Senior Linux / SRE",
    prompt: "A container reports ENOSPC while the host has 200 GB free. Walk me through your response.",
    points: [
      "Clarify impact, exact failing path, scope, and recent changes.",
      "Map the path to its container mount, writable layer, quota, or volume.",
      "Compare block, inode, quota, and runtime-limit evidence before changing state.",
      "Identify the producer and retention policy before proposing bounded cleanup.",
      "Define system and user-visible recovery checks.",
    ],
    rubric: "Strong answers distinguish symptom, immediate cause, and root cause; preserve evidence; mention mount namespaces and inode exhaustion; and verify a real upload after recovery.",
  },
  {
    role: "Platform / Networking",
    prompt: "Small HTTPS requests succeed, but larger responses fail across one routed boundary. How do you investigate without guessing?",
    points: [
      "Separate affected path, direction, payload size, client population, and time window.",
      "Trace DNS, route selection, MTU, TCP retransmission, TLS, proxy, and response framing.",
      "Compare packet evidence at both sides of the boundary and test a safe control path.",
      "Check whether NAT, firewall state, load-balancer limits, or PMTUD filtering explains the threshold.",
      "Mitigate with a reversible scoped change and verify both success and error rates.",
    ],
    rubric: "Strong answers do not call it a generic network issue. They name the next observation, its proof boundary, and the smallest reversible test.",
  },
  {
    role: "SRE / Reliability",
    prompt: "The availability dashboard is green, but customers in one region report failed checkouts. What do you challenge first?",
    points: [
      "Define the user journey and valid population before trusting an aggregate objective.",
      "Compare black-box regional probes with white-box service and dependency signals.",
      "Check missing telemetry, sampling, label cardinality, timestamp skew, and aggregation windows.",
      "Contain the customer impact while preserving a hypothesis table and incident timeline.",
      "Repair the SLI, alert, ownership, and runbook so the same blind spot cannot recur.",
    ],
    rubric: "Strong answers treat a green dashboard as evidence about its query, not proof that the customer journey is healthy.",
  },
];

export default function InteractivePractice() {
  const [mode, setMode] = useState<Mode>("incident");
  const [card, setCard] = useState(0);
  const [revealed, setRevealed] = useState(false);
  const [feedback, setFeedback] = useState("");
  const [teachBack, setTeachBack] = useState("");
  const [saved, setSaved] = useState(false);
  const [interviewCard, setInterviewCard] = useState(0);

  useEffect(() => {
    let frame = 0;
    try {
      const stored = Number.parseInt(window.localStorage.getItem("devops-sre-interview-scenario") ?? "", 10);
      if (Number.isInteger(stored) && stored >= 0 && stored < interviewQuestions.length) {
        frame = window.requestAnimationFrame(() => setInterviewCard(stored));
      }
    } catch { /* Practice remains usable when browser storage is unavailable. */ }
    return () => window.cancelAnimationFrame(frame);
  }, []);

  useEffect(() => {
    try { window.localStorage.setItem("devops-sre-interview-scenario", String(interviewCard)); }
    catch { /* Persistence is a convenience, not a requirement for practice. */ }
  }, [interviewCard]);


  const saveTeachBack = () => {
    window.localStorage.setItem("devops-sre-teachback", teachBack);
    setSaved(true);
  };
  const loadTeachBack = () => {
    setTeachBack(window.localStorage.getItem("devops-sre-teachback") ?? "");
    setSaved(false);
  };

  const moveTab = (currentIndex: number, direction: -1 | 1) => {
    const nextIndex = (currentIndex + direction + modes.length) % modes.length;
    const next = modes[nextIndex].id;
    setMode(next);
    window.requestAnimationFrame(() => document.getElementById(`practice-tab-${next}`)?.focus());
  };


  return (
    <section className="practice-section" id="practice">
      <div className="section-heading light">
        <div>
          <p className="eyebrow">ACTIVE PRACTICE</p>
          <h2>Make the knowledge survive pressure.</h2>
          <p className="section-intro">Switch formats until you can recognize, operate, explain, and defend the same system.</p>
        </div>
      </div>
      <nav className="mode-tabs" aria-label="Learning modes" role="tablist">
        {modes.map((item, index) => (
          <button
            aria-controls="practice-panel"
            aria-selected={mode === item.id}
            className={mode === item.id ? "active" : ""}
            id={`practice-tab-${item.id}`}
            key={item.id}
            onClick={() => setMode(item.id)}
            onKeyDown={(event) => {
              if (event.key === "ArrowRight") { event.preventDefault(); moveTab(index, 1); }
              if (event.key === "ArrowLeft") { event.preventDefault(); moveTab(index, -1); }
            }}
            role="tab"
            tabIndex={mode === item.id ? 0 : -1}
            type="button"
          >
            <strong>{item.label}</strong>
            <small>{item.detail}</small>
          </button>
        ))}
      </nav>
      <div className="practice-stage" id="practice-panel" role="tabpanel" aria-labelledby={`practice-tab-${mode}`} tabIndex={0}>
        {mode === "incident" && (
          <div className="mode-content incident-mode">
            <div className="mode-kicker">INCIDENT / DECISION 1 OF 3</div>
            <h3>The API reports ENOSPC. `/var` shows 48% block use. What do you do next?</h3>
            <div className="choice-list">
              {incidentChoices.map((choice) => (
                <button key={choice.label} type="button" onClick={() => setFeedback(choice.feedback)}>
                  <span>{choice.label}</span><small>Choose this move</small>
                </button>
              ))}
            </div>
            {feedback && <div aria-live="polite" className={feedback.startsWith("Correct") ? "feedback correct" : "feedback warning"}>{feedback}</div>}
            <p className="memory-line"><strong>Operator instinct:</strong> preserve evidence, inspect the exact path, and choose the smallest informative move.</p>
          </div>
        )}
        {mode === "recall" && (
          <div className="mode-content recall-mode">
            <div className="mode-kicker">MEMORY CARD {card + 1} OF {flashcards.length}</div>
            <button aria-pressed={revealed} className="flashcard" type="button" onClick={() => setRevealed(!revealed)}>
              <span>{revealed ? "ANSWER" : "QUESTION"}</span>
              <strong>{revealed ? flashcards[card].a : flashcards[card].q}</strong>
              <small>{revealed ? "Say it once without reading" : "Answer aloud, then reveal"}</small>
            </button>
            <button className="next-card" type="button" onClick={() => { setCard((card + 1) % flashcards.length); setRevealed(false); }}>Next card -&gt;</button>
          </div>
        )}
        {mode === "teach" && (
          <div className="mode-content teach-mode">
            <div className="mode-kicker">FEYNMAN TEACH-BACK</div>
            <h3>Explain inode exhaustion to a developer whose upload just failed.</h3>
            <p>Cover the symptom, exact filesystem, blocks versus inodes, safe remediation, and verification.</p>
            <label className="sr-only" htmlFor="inode-teachback">Your inode exhaustion explanation</label>
            <textarea id="inode-teachback" value={teachBack} onChange={(event) => { setTeachBack(event.target.value); setSaved(false); }} placeholder="When you see ENOSPC..." />
            <div className="teach-actions">
              <div><button type="button" onClick={saveTeachBack}>Save on this device</button>
              <button className="load-note" type="button" onClick={loadTeachBack}>Load saved note</button></div>
              <span aria-live="polite">{saved ? "Saved locally - not uploaded" : `${teachBack.trim().split(/\s+/).filter(Boolean).length} words`}</span>
            </div>
          </div>
        )}
        {mode === "interview" && (
          <div className="mode-content interview-mode">
            <div className="mode-kicker">{interviewQuestions[interviewCard].role} / SCENARIO {interviewCard + 1} OF {interviewQuestions.length}</div>
            <h3>{interviewQuestions[interviewCard].prompt}</h3>
            <ol>
              {interviewQuestions[interviewCard].points.map((point) => <li key={point}>{point}</li>)}
            </ol>
            <details>
              <summary>Reveal scoring rubric</summary>
              <p>{interviewQuestions[interviewCard].rubric}</p>
            </details>
            <button className="next-card" type="button" onClick={() => setInterviewCard((interviewCard + 1) % interviewQuestions.length)}>Next scenario -&gt;</button>
            <button className="load-note" type="button" onClick={() => { setInterviewCard(0); try { window.localStorage.removeItem("devops-sre-interview-scenario"); } catch { /* Local reset remains usable without storage. */ } }}>Reset interview rotation</button>
          </div>
        )}
      </div>
    </section>
  );
}
