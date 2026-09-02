"use client";

import { useEffect, useMemo, useState } from "react";
import { formatMockDuration, mockAreas, mockEvidenceMarkdown, mockRoles, questionsForRoleAndArea, type MockArea, type MockRole } from "./interview-mock-state";

function downloadText(filename: string, value: string): void {
  const blob = new Blob([value], { type: "text/markdown;charset=utf-8" });
  const url = URL.createObjectURL(blob);
  const anchor = document.createElement("a");
  anchor.href = url;
  anchor.download = filename;
  anchor.click();
  URL.revokeObjectURL(url);
}

export default function InterviewMockRunner() {
  const [role, setRole] = useState<MockRole>("SRE");
  const [area, setArea] = useState<MockArea>("Incident response");
  const questions = useMemo(() => questionsForRoleAndArea(role, area), [role, area]);
  const [questionIndex, setQuestionIndex] = useState(0);
  const [response, setResponse] = useState("");
  const [confidence, setConfidence] = useState(3);
  const [elapsedSeconds, setElapsedSeconds] = useState(0);
  const [running, setRunning] = useState(false);
  const [answerVisible, setAnswerVisible] = useState(false);
  const question = questions[questionIndex] ?? questions[0];

  useEffect(() => {
    if (!running) return;
    const timer = window.setInterval(() => setElapsedSeconds((value) => value + 1), 1000);
    return () => window.clearInterval(timer);
  }, [running]);

  const changeRole = (nextRole: MockRole) => {
    setRole(nextRole);
    setQuestionIndex(0);
    setResponse("");
    setConfidence(3);
    setElapsedSeconds(0);
    setRunning(false);
    setAnswerVisible(false);
  };

  const changeArea = (nextArea: MockArea) => {
    setArea(nextArea);
    setQuestionIndex(0);
    setResponse("");
    setConfidence(3);
    setElapsedSeconds(0);
    setRunning(false);
    setAnswerVisible(false);
  };

  const nextQuestion = () => {
    setQuestionIndex((index) => (index + 1) % questions.length);
    setResponse("");
    setConfidence(3);
    setElapsedSeconds(0);
    setRunning(false);
    setAnswerVisible(false);
  };

  const exportRecord = () => downloadText(
    `reliability-atlas-mock-${question.id}.md`,
    mockEvidenceMarkdown({ role, area, question, response, confidence, elapsedSeconds, exportedAt: new Date().toISOString() }),
  );

  return <section className="mock-interview" aria-labelledby="mock-interview-title">
    <div className="mock-interview-heading">
      <div><p className="eyebrow">TIMED MOCK / PRIVATE PRACTICE</p><h2 id="mock-interview-title">Speak first. Compare second. Export your own record.</h2><p>This is a local practice aid. It never assigns a hiring score or changes your learning ledger.</p></div>
      <output aria-label="Elapsed response time" className="mock-timer">{formatMockDuration(elapsedSeconds)}</output>
    </div>
    <fieldset className="mock-role-picker"><legend>Choose a role focus</legend><div>{mockRoles.map((value) => <button aria-pressed={role === value} key={value} onClick={() => changeRole(value)} type="button">{value}</button>)}</div></fieldset>
    <fieldset className="mock-role-picker"><legend>Choose the skill area to exercise</legend><div>{mockAreas.map((value) => <button aria-pressed={area === value} key={value} onClick={() => changeArea(value)} type="button">{value}</button>)}</div></fieldset>
    <article className="mock-question">
      <p className="mode-kicker">{role.toUpperCase()} / {area.toUpperCase()} / QUESTION {questionIndex + 1} OF {questions.length}</p>
      <h3>{question.prompt}</h3>
      <dl className="mock-question-meta"><div><dt>Topic</dt><dd>{question.topic}</dd></div><div><dt>Difficulty</dt><dd>{question.difficulty}</dd></div><div><dt>Expected level</dt><dd>{question.expectedLevel}</dd></div></dl>
      <p><strong>What the interviewer is evaluating:</strong> {question.evaluator}</p>
      <label htmlFor="mock-response">Your spoken-answer outline or written response</label>
      <textarea id="mock-response" maxLength={12000} onChange={(event) => setResponse(event.target.value)} placeholder="Frame impact, map the path, state your evidence, choose the smallest safe move, and explain verification." value={response} />
      <div className="mock-controls">
        <button aria-pressed={running} onClick={() => setRunning((value) => !value)} type="button">{running ? "Pause timer" : "Start timer"}</button>
        <button className="load-note" onClick={() => { setElapsedSeconds(0); setRunning(false); }} type="button">Reset timer</button>
        <label>Confidence <select aria-label="Self-reported confidence" onChange={(event) => setConfidence(Number(event.target.value))} value={confidence}>{[1, 2, 3, 4, 5].map((value) => <option key={value} value={value}>{value} / 5</option>)}</select></label>
      </div>
      <details onToggle={(event) => setAnswerVisible((event.currentTarget as HTMLDetailsElement).open)}>
        <summary>Reveal a strong-answer model</summary>
        <p>{question.strongAnswer}</p>
        <h4>Why this reasoning works</h4><p>{question.deeperExplanation}</p>
        <h4>Production example</h4><p>{question.productionExample}</p>
        <h4>Weak-answer warning signs</h4><ul className="mock-warning-list">{question.weakAnswerWarnings.map((warning) => <li key={warning}>{warning}</li>)}</ul>
        <h4>Senior follow-ups</h4><ul>{question.followUps.map((followUp) => <li key={followUp}>{followUp}</li>)}</ul>
      </details>
      <div className="mock-actions"><button onClick={nextQuestion} type="button">Next question -&gt;</button><button className="load-note" disabled={running} onClick={exportRecord} type="button">Export private practice record</button></div>
      <p className="mock-boundary">{answerVisible ? "Model answer revealed. Compare the reasoning structure, not exact wording." : "Keep the answer concealed until you have spoken or written your own reasoning."} Your response stays in this page unless you explicitly export it.</p>
    </article>
  </section>;
}
