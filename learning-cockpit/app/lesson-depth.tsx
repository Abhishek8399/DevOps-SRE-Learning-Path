import {
  commandDecoders,
  type CommandDecoderLessonId,
} from "./lessons/command-decoders";
import {
  lessonGlossaries,
  type LessonGlossaryId,
} from "./lessons/lesson-glossaries";
import { lessonAnswerGuides } from "./lessons/lesson-answer-guides";

export type LessonDepthId = LessonGlossaryId & CommandDecoderLessonId;

export function LessonGlossary({ lessonId }: { lessonId: LessonDepthId }) {
  const entries = lessonGlossaries[lessonId];

  return (
    <section className="depth-section glossary-section" id={`${lessonId}-vocabulary`}>
      <header className="depth-heading">
        <p className="lesson-label">WORDS YOU NEED BEFORE WE CONTINUE</p>
        <h3>No unexplained terms. Build the language before using the tools.</h3>
        <p>
          Read each plain meaning first. Then connect it to the precise Linux meaning
          and the reason an SRE cares. These are working definitions for diagnosis,
          not vocabulary to memorize without context.
        </p>
      </header>
      <div className="glossary-grid">
        {entries.map((entry, index) => (
          <article className="glossary-card" key={entry.term}>
            <div className="glossary-term">
              <span>{String(index + 1).padStart(2, "0")}</span>
              <h4>{entry.term}</h4>
            </div>
            <div className="glossary-plain">
              <strong>IN EVERYDAY WORDS</strong>
              <p>{entry.plainMeaning}</p>
            </div>
            <dl>
              <div>
                <dt>PRECISE TECHNICAL MEANING</dt>
                <dd>{entry.technicalMeaning}</dd>
              </div>
              <div>
                <dt>WHY THIS MATTERS ON CALL</dt>
                <dd>{entry.sreRelevance}</dd>
              </div>
            </dl>
          </article>
        ))}
      </div>
    </section>
  );
}

export function CommandDecoderGuide({ lessonId }: { lessonId: LessonDepthId }) {
  const decoders = commandDecoders[lessonId];

  return (
    <section className="depth-section decoder-section" id={`${lessonId}-output-decoders`}>
      <header className="depth-heading">
        <p className="lesson-label">READ THE OUTPUT LIKE AN SRE</p>
        <h3>Do not run a command until you know the question it answers.</h3>
        <p>
          The sample output below is realistic teaching data, not a promised healthy
          value. Decode the columns, read combinations rather than one number, and use
          the next command only to test a stated hypothesis.
        </p>
      </header>

      {lessonId === "cpu-memory-pressure" ? (
        <aside className="decoder-correction">
          <strong>Important separation</strong>
          <p>
            <code>uptime</code> does not contain <code>si</code>, <code>so</code>, <code>bi</code>,
            or <code>bo</code>. It shows clock time, time since boot, login-session count,
            and three load averages. Those four short fields belong to <code>vmstat</code>:
            swap in, swap out, block input, and block output. Mixing the two commands
            leads to the wrong diagnosis, so this chapter decodes them separately.
          </p>
        </aside>
      ) : null}

      <div className="decoder-list">
        {decoders.map((decoder, decoderIndex) => (
          <article className="decoder-card" key={decoder.command}>
            <header>
              <span>COMMAND DECODER {String(decoderIndex + 1).padStart(2, "0")}</span>
              <h4 id={`${lessonId}-decoder-${decoderIndex + 1}`}>{decoder.title}</h4>
            </header>
            <div className="decoder-question">
              <strong>QUESTION THIS COMMAND ANSWERS</strong>
              <p>{decoder.questionAnswered}</p>
            </div>
            <pre className="decoder-command"><code>{decoder.command}</code></pre>
            <div className="decoder-prerequisite">
              <strong>BEFORE YOU RUN IT</strong>
              <p>{decoder.prerequisiteExplanation}</p>
            </div>
            <div className="sample-output">
              <strong>REALISTIC SAMPLE OUTPUT</strong>
              <pre><code>{decoder.sampleOutput}</code></pre>
            </div>
            <div className="field-table-wrap" role="region" tabIndex={0} aria-labelledby={`${lessonId}-decoder-${decoderIndex + 1}`}>
              <table className="field-table">
                <caption>Field-by-field explanation for <code>{decoder.command}</code></caption>
                <thead>
                  <tr><th>FIELD</th><th>PLAIN MEANING</th><th>HOW AN SRE USES IT</th><th>DO NOT MISREAD IT AS</th></tr>
                </thead>
                <tbody>
                  {decoder.fields.map((field) => (
                    <tr key={field.token}>
                      <th scope="row"><code>{field.token}</code></th>
                      <td data-label="PLAIN MEANING">{field.plainMeaning}</td>
                      <td data-label="HOW AN SRE USES IT">{field.operationalUse}</td>
                      <td data-label="DO NOT MISREAD IT AS">{field.trap}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
            <div className="pattern-grid">
              {decoder.interpretationPatterns.map((pattern) => (
                <article key={pattern.signalCombination}>
                  <strong>WHEN YOU SEE</strong><p>{pattern.signalCombination}</p>
                  <strong>THINK</strong><p>{pattern.likelyHypothesis}</p>
                  <strong>PROVE NEXT</strong><p>{pattern.safestNextEvidence}</p>
                </article>
              ))}
            </div>
            <aside className="advanced-note"><strong>ADVANCED NOTE</strong><p>{decoder.advancedNote}</p></aside>
          </article>
        ))}
      </div>
    </section>
  );
}

export function LessonAnswerGuide({ lessonId }: { lessonId: LessonDepthId }) {
  const guides = lessonAnswerGuides[lessonId];

  return (
    <section className="depth-section answer-guide-section" id={`${lessonId}-answers`}>
      <header className="depth-heading">
        <p className="lesson-label">QUESTIONS WITH COMPLETE TEACHING ANSWERS</p>
        <h3>Try it in your own words, then study the full reasoning.</h3>
        <p>
          These are not answer keys made of keywords. Each answer starts directly,
          rebuilds the foundation, follows the causal chain, and finishes with the
          evidence and production judgment expected from a senior engineer.
        </p>
      </header>
      <div className="answer-guide-list">
        {guides.map((guide, index) => (
          <details className="answer-card" key={guide.id}>
            <summary>
              <div>
                <span>{guide.kind.toUpperCase()} / {String(index + 1).padStart(2, "0")}</span>
                <h4>{guide.question}</h4>
              </div>
              <b className="answer-reveal-label">Reveal complete teaching answer</b>
              <b className="answer-hide-label">Hide teaching answer</b>
            </summary>
            <section className="answer-first">
              <strong>THE DIRECT ANSWER</strong>
              <p>{guide.shortAnswer}</p>
            </section>
            <div className="answer-foundation">
              <strong>BUILD THE FOUNDATION</strong>
              <p>{guide.foundationAnswer}</p>
            </div>
            <section className="reasoning-chain">
              <strong>REASONING, STEP BY STEP</strong>
              <ol>
                {guide.reasoningSteps.map((step) => <li key={step}>{step}</li>)}
              </ol>
            </section>
            <section className="production-answer">
              <strong>HOW A SENIOR SRE WOULD ANSWER</strong>
              <p>{guide.productionAnswer}</p>
            </section>
            <aside className="weak-answer">
              <div><strong>COMMON WEAK ANSWER</strong><p>{guide.commonWeakAnswer}</p></div>
              <div><strong>WHY IT IS WEAK</strong><p>{guide.whyWeak}</p></div>
            </aside>
            <section className="answer-evidence">
              <strong>EVIDENCE OR COMMANDS THAT SUPPORT THE ANSWER</strong>
              <div>
                {guide.evidenceOrCommands.map((evidence) => (
                  <article key={`${evidence.classification}-${evidence.item}`}>
                    <span>{evidence.classification}</span>
                    <code>{evidence.item}</code>
                    <p>{evidence.interpretation}</p>
                  </article>
                ))}
              </div>
            </section>
            <section className="answered-followups">
              <strong>FOLLOW-UP QUESTIONS, ALREADY ANSWERED</strong>
              <dl>
                {guide.followUpQuestions.map((followUp) => (
                  <div key={followUp.question}>
                    <dt>{followUp.question}</dt>
                    <dd>{followUp.answer}</dd>
                  </div>
                ))}
              </dl>
            </section>
          </details>
        ))}
      </div>
    </section>
  );
}
