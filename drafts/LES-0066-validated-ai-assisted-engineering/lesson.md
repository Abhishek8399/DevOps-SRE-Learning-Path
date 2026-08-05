---
{"schemaVersion":1,"kind":"lesson","id":"LES-0066","slug":"validated-ai-assisted-engineering","aliases":["V07-L01","validated-ai-assisted-engineering"],"curriculumIds":["AIO-001"],"route":"/book/ai/validated-ai-assisted-engineering","order":1,"volume":"07-ai-engineering","title":"Validated AI-assisted engineering: probability, grounding, tools, and human authority","summary":"Build AI-assisted systems by defining tasks and evaluation first; tracing tokens, context, embeddings and retrieval; constraining tools and agents; and preserving validation, privacy, rollback and accountable human authority.","domain":"ai","level":{"from":"foundation","to":"advanced"},"estimatedMinutes":600,"prerequisiteLessonIds":["LES-0018","LES-0051","LES-0057"],"prerequisiteCurriculumIds":["AUT-002","DST-001","SEC-001"],"testedEnvironments":[{"platform":"Primary and official sources","version":"NIST, OWASP, Google, Hugging Face and research sources reviewed 2026-08-05","support":"concept-only","notes":"Source review does not establish model or product behavior."},{"platform":"Ubuntu","version":"24.04 normal-user offline model","support":"required","notes":"Guarded deterministic evidence-boundary model only."},{"platform":"Python","version":"3 standard library","support":"required","notes":"Local JSON decisions; no model, API, network, embedding or third-party package."}],"targetRoles":["site-reliability-engineer","platform-engineer","devops-engineer","software-engineer","machine-learning-engineer","ml-platform-engineer","security-engineer","solutions-architect","technical-lead"],"learningObjectives":["Define the user decision, harm, abstention, non-AI baseline and measurable acceptance before selecting a model.","Explain training, inference, probability and generative sampling without treating fluent text as stored truth.","Trace text through normalization, tokenization, token IDs, context, attention and generated tokens.","Distinguish context capacity from effective use and test evidence position, truncation and distraction.","Define embedding identity and similarity limits before semantic retrieval.","Trace RAG through corpus, chunk, embedding, filter, candidates, rerank, prompt, output and citation verification.","Separate model generation from deterministic validation, authorization and side-effect execution.","Treat direct and indirect prompt content as untrusted data, never authorization.","Design tools with closed schemas, least privilege, idempotency, approval and audited results.","Define agent loops as bounded state machines with budgets, terminal states and reconciliation.","Build held-out sliced evaluations with cost-sensitive metrics and calibrated judges.","Operate with version lineage, privacy, observability, cost, fallback, rollback and human appeal."],"productionSignals":["user task decision harm abstention and non-AI baseline","request actor purpose policy consent","model provider revision parameters deployment","prompt template hierarchy digest","tokenizer version token count truncation context budget","corpus document chunk version score filter rank","embedding model dimensions metric index version","output schema validation grounded claims","citation source span version verification","tool schema arguments authorization approval idempotency result","agent run step budget deadline terminal reason","evaluation split provenance contamination population slice","metric threshold uncertainty failure cost","judge version rubric calibration human audit","untrusted-content source and injection decision","input/output retention redaction deletion","stage latency token throughput saturation fallback","cost per accepted outcome and tool call","rollback version compatibility canary","incident audit appeal owner"],"diagrams":[{"id":"LES-0066-DIA-001","title":"AI-assisted decision system","direction":"left-to-right","boundaries":["task and harm","non-AI baseline","data and context","model proposal","validation","authorization and human decision","outcome"],"evidencePoints":["task","baseline","data version","model version","validation","approval","feedback"],"textAlternative":"A model is one probabilistic component between defined evidence and deterministic validation, authorization, accountable decision and outcome."},{"id":"LES-0066-DIA-002","title":"Text to generated token path","direction":"left-to-right","boundaries":["raw text","normalization","token IDs","context","attention and model","next-token distribution","output"],"evidencePoints":["bytes","normalizer","tokenizer","budget","model","probabilities","parameters"],"textAlternative":"Raw text becomes token IDs in a bounded context; a model produces distributions and a decoding policy selects output."},{"id":"LES-0066-DIA-003","title":"Grounded retrieval path","direction":"left-to-right","boundaries":["corpus","chunk and embedding","index","query and filter","candidates","prompt context","claims and citations"],"evidencePoints":["corpus version","chunk ID","embedding contract","scores","recall","source spans","verified claims"],"textAlternative":"Grounding depends on corpus authority, embedding identity, measured retrieval, provenance and claim-level verification."},{"id":"LES-0066-DIA-004","title":"Tool and agent authority path","direction":"cyclic","boundaries":["goal and policy","model proposal","closed schema","authorization and approval","idempotent execution","validated observation","terminal or next step"],"evidencePoints":["run ID","call","schema","policy","operation key","receipt","budget"],"textAlternative":"Trusted code validates, authorizes and executes a model's proposed call before a bounded loop continues."},{"id":"LES-0066-DIA-005","title":"Evaluation evidence pyramid","direction":"hierarchical","boundaries":["schema tests","golden tasks","held-out adversarial cases","population slices","calibrated review","online outcome"],"evidencePoints":["test version","expected","contamination","slice metrics","agreement","appeal"],"textAlternative":"Evaluation grows from deterministic tests through held-out sliced evidence to calibrated review and monitored outcomes."},{"id":"LES-0066-DIA-006","title":"AI release and recovery envelope","direction":"hierarchical","boundaries":["version lineage","offline gate","shadow/canary","authority ceiling","privacy/security","capacity/cost","rollback/appeal"],"evidencePoints":["manifest","regression","cohort","permissions","lifecycle","budget","recovery"],"textAlternative":"Release requires lineage, evaluation, bounded authority/data, capacity and tested rollback plus appeal."}],"commands":[{"id":"LES-0066-CMD-001","question":"Is the offline model safe?","risk":"read-only","command":"bash lab.sh doctor","runFrom":"LES-0066 support/lab as normal Ubuntu 24.04 user","expectedBranches":[{"when":"doctor=pass","meaning":"guards pass","nextEvidence":"setup"},{"when":"lab=fail","meaning":"boundary failed","nextEvidence":"correct without bypass"}],"proves":"local preconditions","doesNotProve":"AI behavior"},{"id":"LES-0066-CMD-002","question":"Can bounded state initialize?","risk":"mutating-bounded","command":"bash lab.sh setup","runFrom":"LES-0066 support/lab","expectedBranches":[{"when":"setup=pass","meaning":"state validates","nextEvidence":"baseline"},{"when":"failure","meaning":"guard failed","nextEvidence":"preserve first error"}],"proves":"bounded initialization","doesNotProve":"model setup","cleanup":"Run bash lab.sh cleanup."},{"id":"LES-0066-CMD-003","question":"Does baseline cross every boundary?","risk":"read-only","command":"bash lab.sh evaluate baseline","runFrom":"LES-0066 support/lab after setup","expectedBranches":[{"when":"boundary=operable","meaning":"conditions pass","nextEvidence":"negative cases"}],"proves":"model decision","doesNotProve":"production readiness"},{"id":"LES-0066-CMD-004","question":"Is the task measurable?","risk":"read-only","command":"bash lab.sh evaluate task-not-defined","runFrom":"LES-0066 support/lab","expectedBranches":[{"when":"boundary=task-contract","meaning":"outcome contract missing","nextEvidence":"define task and abstention"}],"proves":"task gap","doesNotProve":"business value"},{"id":"LES-0066-CMD-005","question":"Is the population representative?","risk":"read-only","command":"bash lab.sh evaluate population-unrepresentative","runFrom":"LES-0066 support/lab","expectedBranches":[{"when":"boundary=population","meaning":"aggregate cannot support users","nextEvidence":"build slices"}],"proves":"coverage gap","doesNotProve":"fairness"},{"id":"LES-0066-CMD-006","question":"Does evidence survive context?","risk":"read-only","command":"bash lab.sh evaluate context-evidence-lost","runFrom":"LES-0066 support/lab","expectedBranches":[{"when":"boundary=context-use","meaning":"fit does not prove use","nextEvidence":"position tests"}],"proves":"context gap","doesNotProve":"attention"},{"id":"LES-0066-CMD-007","question":"Is retrieval measured?","risk":"read-only","command":"bash lab.sh evaluate retrieval-baseline-missing","runFrom":"LES-0066 support/lab","expectedBranches":[{"when":"boundary=retrieval-baseline","meaning":"missing evidence unmeasured","nextEvidence":"exact/labeled set"}],"proves":"retrieval gap","doesNotProve":"answer quality"},{"id":"LES-0066-CMD-008","question":"Is retrieved instruction untrusted?","risk":"read-only","command":"bash lab.sh evaluate prompt-injection-trusted","runFrom":"LES-0066 support/lab","expectedBranches":[{"when":"boundary=instruction-trust","meaning":"data crossed authority","nextEvidence":"separate policy"}],"proves":"trust gap","doesNotProve":"injection resistance"},{"id":"LES-0066-CMD-009","question":"Is tool authority least privilege?","risk":"read-only","command":"bash lab.sh evaluate tool-authority-excessive","runFrom":"LES-0066 support/lab","expectedBranches":[{"when":"boundary=tool-authority","meaning":"effect scope excessive","nextEvidence":"reduce privilege"}],"proves":"authority gap","doesNotProve":"authorization"},{"id":"LES-0066-CMD-010","question":"Can human review veto?","risk":"read-only","command":"bash lab.sh evaluate human-review-ceremonial","runFrom":"LES-0066 support/lab","expectedBranches":[{"when":"boundary=human-review","meaning":"review ineffective","nextEvidence":"time context competence veto"}],"proves":"oversight gap","doesNotProve":"review quality"},{"id":"LES-0066-CMD-011","question":"Is model judge calibrated?","risk":"read-only","command":"bash lab.sh evaluate judge-not-calibrated","runFrom":"LES-0066 support/lab","expectedBranches":[{"when":"boundary=judge-calibration","meaning":"score lacks agreement evidence","nextEvidence":"human calibration"}],"proves":"judge gap","doesNotProve":"evaluation validity"},{"id":"LES-0066-CMD-012","question":"Do cases and cleanup pass?","risk":"mutating-bounded","command":"bash verify.sh","runFrom":"LES-0066 support/lab from absent state","expectedBranches":[{"when":"verify=pass","meaning":"24 branches pass","nextEvidence":"retain limitations"},{"when":"failure","meaning":"candidate rejected","nextEvidence":"preserve failure"}],"proves":"teaching lifecycle","doesNotProve":"model API retrieval agent tool evaluation or production behavior","cleanup":"Verifier proves state absence."}],"labs":[{"id":"LES-0066-LAB-001","title":"Guided AI evidence and authority model","mode":"guided","environment":"Ubuntu 24.04 normal user with Bash and Python","timeMinutes":240,"privilege":"normal user; root refused","network":"none","changes":["UID-scoped temporary root","synthetic fixture"],"abortConditions":["root","credential","endpoint","symlink","wrong owner","unknown artifact"],"recovery":"Preserve first failure; change only copied fixture or candidate code.","cleanupProof":"Exact inventory and root absence.","path":"drafts/LES-0066-validated-ai-assisted-engineering/support/lab"},{"id":"LES-0066-LAB-002","title":"Independent AI-assisted engineering transfer","mode":"independent","environment":"Reviewer-owned disposable local stub or sanitized packet","timeMinutes":240,"privilege":"normal user; reviewer owns faults","network":"isolated local only or none","changes":["synthetic prompts documents evaluations tool proposals","bounded local state"],"abortConditions":["shared service","real credential","customer data","external effect","unbounded loop","unknown cleanup"],"recovery":"Preserve manifests and reset through reviewer harness.","cleanupProof":"Reviewer proves processes, files, ports, caches and synthetic data absent.","path":"drafts/LES-0066-validated-ai-assisted-engineering/support/lab"}],"incidents":[{"id":"LES-0066-INC-001","signal":"Generated infrastructure parses but opens public access.","firstThought":"Syntax is not policy or intent validation.","safePath":"Stop apply, bind output/diff, run deterministic policy tests, require approval and rollback.","trap":"Ask the model if it is safe."},{"id":"LES-0066-INC-002","signal":"Grounded answer cites unsupported documents.","firstThought":"Provenance or entailment failed.","safePath":"Bind claims to source spans, verify, abstain and add claim evaluation.","trap":"Increase context."},{"id":"LES-0066-INC-003","signal":"A document makes an agent send sensitive data.","firstThought":"Indirect injection crossed excessive tool authority.","safePath":"Stop/revoke, preserve trace, assess impact, reduce privilege and require approval.","trap":"Rewrite only the prompt."},{"id":"LES-0066-INC-004","signal":"Offline score rises while one region regresses.","firstThought":"Aggregate evaluation hid a population slice.","safePath":"Hold rollout, inspect split/slices/harm, restore and repair coverage.","trap":"Average away the region."},{"id":"LES-0066-INC-005","signal":"Agent latency/cost rise without success gain.","firstThought":"Loop or context growth consumes budget without progress.","safePath":"Bind step/tool/token timeline, terminate, fallback and redesign.","trap":"Increase iteration limits."}],"assessmentIds":["ASM-0181","ASM-0182","ASM-0183"],"referenceIds":["REF-0748","REF-0749","REF-0750","REF-0751","REF-0752","REF-0753","REF-0754","REF-0755","REF-0756","REF-0757","REF-0758","REF-0759","REF-0760","REF-0761","REF-0762"],"contentStatus":"substantive-draft","masteryBoundary":"publication-does-not-award-mastery","lastReviewed":"2026-08-05","reviewAfter":"2027-02-05","limitations":["Offline model is not an AI model, tokenizer, retriever, agent, tool, evaluator or benchmark.","Synthetic decisions cannot prove truthfulness, safety, fairness, security, privacy or oversight.","No prompt, token, embedding, socket, credential or external effect exists.","Provider behavior, limits, prices and interfaces are version-dependent.","Formal review, publication, runtime, transfer, recall and learner evidence remain required."]}
---

# Validated AI-assisted engineering: probability, grounding, tools, and human authority

## What you see and first thought

An AI assistant produces a polished infrastructure change. It parses, the explanation sounds confident and the tool reports success. A security reviewer then notices that the change exposed a private service publicly.

The failure is not simply "the model hallucinated." The engineering system allowed generated text to cross boundaries without proof:

```text
request -> inferred intent -> generated configuration -> syntax
        -> policy and security meaning -> authorization -> effect -> outcome
```

Syntax covered one boundary. Fluency covered none.

Keep this sentence:

> A model produces a probabilistic proposal. Trusted software and accountable people decide whether that proposal may become an effect.

When output is wrong, bind the user task, input data, instruction hierarchy, context construction, model/version, retrieval evidence, generation parameters, validation, tool authority, approval, side effect and observed outcome. AI can accelerate drafting and automation; it can also make incorrect work arrive faster and appear more credible.

## Terms before commands

### AI, machine learning and a model

**Artificial intelligence** broadly describes systems performing perception, prediction, generation, decision-support or action tasks. **Machine learning** builds behavior from data and optimization rather than encoding every rule. A **model** is the learned mathematical function and parameters mapping inputs to outputs.

Do not use "AI" as an architecture box. Name the task: classify an alert, rank documents, generate a runbook draft, propose a command or select a tool. Each has different evidence and harm.

### Training, validation, test and inference

**Training** changes parameters using examples and an objective. A **validation set** helps select configurations. A **test set** estimates behavior after choices are frozen. **Inference** uses fixed model state to produce output for new input.

If test examples influence prompt or model selection, the test is contaminated and has become development data. Keep a held-out set; version data, splits and every access.

### Probability, score, confidence and calibration

A model may output a probability-like score or a distribution over tokens. The largest score is a selection signal, not proof. **Calibration** asks whether predictions made at a claimed confidence correspond to observed frequencies for a stated population. Token probability does not equal confidence that a complete answer is factually correct.

### Generative model, token and tokenizer

A **generative model** constructs content. Text models operate on **tokens**—words, subwords, punctuation or bytes mapped to IDs. A **tokenizer** includes normalization, pre-tokenization, a vocabulary/model and post-processing.

Characters, words and tokens differ. Cost, latency and context limits commonly apply to tokens. Changing tokenizer or normalization changes input identity, truncation and potentially behavior.

### Context window and effective context

The **context window** is the bounded token sequence available for one generation: instructions, examples, history, retrieved documents, tool observations and requested output.

Information fitting inside the nominal limit is not proof the model will use it correctly. Position, competing text, truncation and task structure matter. Test critical evidence at varied positions with realistic distraction.

### Attention and next-token generation

A transformer uses attention-based computation to combine token representations while respecting architecture and position. At generation time it produces a next-token distribution; decoding selects one token, appends it and repeats.

Sampling settings can change variation. Deterministic-looking settings do not turn generation into a theorem prover, database or authorization engine.

### Embedding and similarity

An **embedding** is a numeric vector representing input under a particular model and preprocessing contract. Similarity functions rank geometric closeness. Closeness is not truth, authorization or business relevance.

Comparable vectors require pinned model/version, preprocessing, dimensions and metric. Retrieval quality needs exact-neighbor or human relevance labels for the target population.

### Retrieval-augmented generation and grounding

**Retrieval-augmented generation** obtains external passages for generation. **Grounding** constrains or checks output against identified evidence or rules.

Retrieval does not guarantee grounding. A document may be absent, parsed badly, missed, truncated, ignored or cited incorrectly. Evaluate corpus coverage, retrieval recall, claim support and abstention separately.

### Prompt, instruction hierarchy and injection

A **prompt** is assembled model input. Systems may distinguish instruction roles, but retrieved pages, email, tickets, logs and tool output remain untrusted data.

**Prompt injection** occurs when content changes behavior outside its intended data role. Delimiters help structure input but do not create a security boundary. Trusted code outside the model enforces authorization.

### Tool and agent

A **tool** is a typed interface through which a model requests a read, computation or mutation. An **agent** is a loop using model output, tools and observations toward a goal.

The model proposes; the host validates schema, authenticates, authorizes exact action/resource, obtains approval, executes idempotently, validates result and records audit. An agent needs step, time, token, cost and effect budgets plus terminal and fallback states.

### Evaluation, oracle and judge

An **evaluation** connects a task population, expected behavior, metric and gate. An **oracle** supplies trusted expected outcomes: deterministic calculation, simulator, reviewed labels or user results. A model **judge** is another instrument, not ground truth; calibrate it against reviewed examples, disagreements and bias.

### Human in the loop

Human presence is not automatically control. Effective review needs context, time, competence, independence and real veto/appeal authority. Clicking approve on hundreds of opaque outputs is a bottleneck and ceremonial control.

## Architecture map

### Decision system

```text
Task and harm -> non-AI baseline -> input/context -> model proposal
                                            -> deterministic validation
                                            -> policy/authorization/approval
                                            -> effect or answer
                                            -> outcome/feedback/appeal
```

The application owns context assembly. Policy code owns allow/deny. The target system owns state. An accountable role owns risk acceptance. The model owns no authority merely because it sits in the middle.

### Grounded answer path

```text
corpus/version -> parse/chunk IDs -> embedding contract -> index
 -> authorized query/filter -> candidates/rerank -> source spans in context
 -> generated claims -> citation support -> answer or abstain
```

Every arrow can fail while the endpoint returns 200. Track identity so each claim can be traced to exact source state and retrieval.

### Tool boundary

```text
untrusted goal/content -> model proposes {tool, arguments}
 -> closed schema -> current identity -> exact authorization
 -> risk-based approval -> idempotent deadline-bound execution
 -> receipt and resulting-state validation -> audit
```

Never place a broad shell, unrestricted HTTP client or administrative credential behind a generic tool and call prompt instructions the safety layer.

### Evaluation and release

```text
task/harm contract -> frozen data provenance/split -> deterministic tests
 -> held-out task and adversarial cases -> critical population slices
 -> calibrated human/judge review -> offline gate
 -> authority-limited shadow/canary -> outcomes/appeal -> rollback/promotion
```

Evaluation is a release system, not a demo score. It needs versions, thresholds, owners and explicit handling for missing evidence.

## Request or state path

### Read-only answer

1. Authenticate requester and determine allowed data scope.
2. Classify task and risk: informational, advisory or decision support.
3. Normalize/tokenize and record prompt-template version.
4. Retrieve only authorized corpus state with document/chunk provenance.
5. Build context under measured budget and explicit truncation.
6. Generate with pinned model and parameters.
7. Parse into a bounded schema when structure is required.
8. Verify citations, deterministic facts and policy constraints.
9. Return answer, uncertainty and source timing—or abstain.
10. Record privacy-safe telemetry and later outcome/appeal.

### Mutating tool call

1. Expose only narrow capabilities.
2. Treat the model call as an untrusted proposal.
3. Reject unknown fields, types and ranges.
4. Bind the real principal and tenant outside the model.
5. Authorize exact action/resource under current policy.
6. Require approval by consequence and reversibility.
7. Add operation ID, idempotency key, deadline and audit context.
8. Execute through a least-privileged adapter.
9. Validate receipt and resulting state.
10. Reconcile unknown outcomes before retry.

### Agent loop

```text
requested -> planned -> awaiting-tool -> observing -> planned
                   \-> awaiting-approval
                   \-> completed | refused | budget-exhausted
                   \-> failed-needs-review
```

Persist run, step, model, prompt, proposal, policy, approval, operation and result identities. Count retries inside one deadline. Terminal failure needs an owner; "the agent will try again" is not an operating model.

## Failure zoom

### Fluent but unsupported answer

Freeze model, prompt, retrieval and request. Ask: did the corpus contain the fact, parsing preserve it, retrieval return it, context retain it, generation use it and the citation support it? Repair the first failed boundary. Changing wording first destroys comparability.

### Indirect injection requests a tool

Treat the document as evidence, not instruction. Stop the run and revoke exposed authority. Preserve content, context, proposal, validation, policy, approval and audit. Assess effects. Fix the content-to-authority crossing, not just wording.

### Evaluation rises while users regress

Bind candidate/baseline, dataset/split, prompt and model. Check contamination, population drift, missing slices, harm-metric mismatch and thresholds. Restore the verified version if impact is material. Add the failure to a governed regression set without leaking the held-out set.

### Agent loops without progress

Stop at deadline/budget. Inspect repeated state, duplicate calls, context growth, tool errors and observation loss. Reconcile effects before replay. Add progress invariants and terminal classes; more steps can increase cost and damage without capability.

### Human review approves harm

Check whether the reviewer saw request, evidence, diff, policy failures, blast radius and alternatives; had enough time and competence; and possessed real veto. Redesign the control and measure its effectiveness.

## Internals and state ownership

### A language model is not a knowledge database

Training changes parameters to improve an objective. Output arises from parameters, context and decoding; it is not a row with a transaction receipt. Factual tasks still require source and freshness verification.

### Context construction is application code

The application selects instructions, history, passages, observations and output constraints. Ordering and truncation are versioned behavior. Store privacy-safe digests and assembly metadata so incidents are reproducible without indiscriminate raw-content logging.

### Retrieval owns a quality budget

Corpus acquisition, parsing, chunking, embedding, filters, ANN candidates and reranking are distinct. Generation cannot cite missing evidence. Measure retrieval recall and authorization before end-answer scoring.

### Policy belongs outside generation

A model may classify or propose. It must not alone enforce tenant access, resources, financial limits or destructive operations. Trusted code resolves current identity and policy against canonical state.

### Effects need distributed-systems discipline

Tool timeouts create unknown outcomes. Stable operation identity, idempotency, deadlines, receipts and reconciliation still apply. Agent reasoning does not remove duplicate or partial-success windows.

### Evaluation data is governed state

Prompts, expected outputs, adversarial cases, labels, rubrics and judge outputs have provenance, privacy, retention and contamination risk. Version them, separate development feedback from held-out acceptance, and record gate changes.

### Human authority includes appeal

For consequential decisions, identify who can stop, override and reverse; how affected people challenge outcomes; and what evidence survives. Oversight without these powers is documentation, not control.

## Evidence table

| Symptom | Bind first | Evidence that belongs together | Safe response |
|---|---|---|---|
| Good demo, unclear value | task contract | user decision, baseline, failure cost, abstention, benefit | define acceptance before tuning |
| High accuracy, missed rare harm | population/metric | confusion counts, base rate, threshold, metrics by slice | choose metric from harm |
| Prompt exceeds context | token budget | tokenizer, component tokens, truncation, output reserve | reject or deliberately compress |
| Evidence present but ignored | effective context | source position, distraction, exact query/response | restructure and regression-test |
| Similar documents irrelevant | retrieval | embedding contract, corpus, filter, exact/labeled top-K | measure and repair recall |
| Citation unsupported | claim provenance | claim, source version/span, retrieval rank, verification | abstain or correct |
| Document changes agent behavior | instruction trust | content, assembled prompt, proposal, policy, effect | separate data from authority |
| Tool has extra fields | schema | raw proposal, schema version, parser rejection, audit | fail closed |
| Allowed tool causes broad damage | authority | principal, action/resource, policy, approval, credential | revoke and reduce |
| Tool timed out | effect outcome | operation ID, request, receipt, target state, retry | reconcile before retry |
| Agent costs rise without progress | loop state | transitions, tokens, tools, repeated state, deadline | terminate and fall back |
| Model judge says pass | validity | rubric, judge version, human labels, agreement, slices | calibrate and audit |
| Human approves unsafe output | oversight | evidence shown, time, workload, competence, veto | redesign control |
| One region regresses | release population | versions, split, regional metrics and outcome | hold or rollback |
| Logs contain sensitive prompts | lifecycle | fields, purpose, redaction, retention, access, deletion | contain and remediate |

Join evidence by request/run, task/version and time. A shared model name is insufficient when prompt, provider revision, corpus, tokenizer, parameters or tools changed.

## Command decoders

The local lab contains no AI. It teaches the order for refusing unsupported claims.

```bash
bash lab.sh doctor
bash lab.sh setup
bash lab.sh status
```

`doctor` refuses root, AI credentials, endpoints, symlinks and unsupported state. `setup` creates a UID-scoped copied fixture. `status` reports model state, not an endpoint.

```bash
bash lab.sh evaluate baseline
bash lab.sh evaluate task-not-defined
bash lab.sh evaluate population-unrepresentative
```

The baseline crosses all encoded boundaries. `task-contract` stops before model choice because no measurable outcome exists. `population` rejects an aggregate result that omits intended users.

```bash
bash lab.sh evaluate context-evidence-lost
bash lab.sh evaluate retrieval-baseline-missing
bash lab.sh evaluate prompt-injection-trusted
bash lab.sh evaluate tool-authority-excessive
```

`context-use` separates fit from effective use. `retrieval-baseline` demands exact or labeled evidence before generation. `instruction-trust` detects data crossing into policy. `tool-authority` detects excessive effect scope; prompt wording cannot repair credentials.

```bash
bash lab.sh evaluate human-review-ceremonial
bash lab.sh evaluate judge-not-calibrated
bash verify.sh
bash lab.sh cleanup
```

`human-review` requires context, time, competence and veto. `judge-calibration` requires agreement evidence against reviewed labels. The verifier covers 24 cases, unknown-artifact refusal and cleanup. It proves the teaching model only.

## Decision path

### Should AI be used?

```text
task and harm defined?
 -> non-AI baseline insufficient?
 -> success, abstention and forbidden failure measurable?
 -> input/output permitted?
 -> authority remains outside model?
 -> fallback, appeal and rollback exist?
otherwise stop, reduce scope or use deterministic design
```

### Why is a grounded answer wrong?

```text
corpus contains answer?
 -> parsing/chunking preserved it?
 -> authorized retrieval returned it?
 -> context retained it?
 -> generation used it?
 -> citation supports each claim?
 -> deterministic/domain checks pass?
```

Stop at the first failed boundary. If retrieval missed evidence, prompt rewriting is not root-cause work.

### May a tool call execute?

```text
known tool and exact schema?
 -> authenticated actor and tenant?
 -> exact action/resource authorized?
 -> within automatic authority ceiling?
 -> informed approval present?
 -> idempotency, deadline and audit attached?
 -> result and unknown outcome reconcilable?
```

Any "no" means refusal, not best effort.

## Guided Ubuntu lab

```bash
cd drafts/LES-0066-validated-ai-assisted-engineering/support/lab
bash lab.sh doctor
bash lab.sh setup
bash lab.sh show baseline
bash lab.sh evaluate baseline
```

Explain what real evidence each field would represent. Create a sheet with task, population, harm, baseline, data/split, model/prompt/tokenizer, corpus/retrieval, metric/gate, authority, rollback and unknowns.

```bash
bash lab.sh evaluate dataset-leak
bash lab.sh evaluate metric-cost-mismatch
bash lab.sh evaluate token-budget-exceeded
bash lab.sh evaluate embedding-contract-mismatch
bash lab.sh evaluate citation-unverified
```

Then run the authority cases:

```bash
bash lab.sh evaluate prompt-injection-trusted
bash lab.sh evaluate tool-schema-loose
bash lab.sh evaluate tool-authority-excessive
bash lab.sh evaluate side-effect-not-idempotent
```

For each, propose an external control: strict parser, allow-listed resolver, current authorization, approval queue, idempotency ledger or reconciliation.

```bash
bash verify.sh
bash lab.sh cleanup
bash lab.sh status
```

Final `status` should refuse absent state. Record that no model or effect was tested. Redraw the decision, RAG, tool and evaluation paths from memory after one day and one week.

## Production transfer

Use a reviewer-owned disposable local stub or approved local model with synthetic data. No production credential, customer prompt, employer document or unrestricted tool is allowed.

The reviewer supplies an unfamiliar task and later changes one major constraint. The learner must:

1. define outcome, harm, abstention and non-AI baseline;
2. create immutable prompt/model/tokenizer/corpus/tool manifests;
3. build held-out normal, edge, adversarial and critical-slice cases;
4. measure deterministic interfaces and task quality separately;
5. inject a retrieved instruction and prove it cannot authorize;
6. propose malformed, overbroad and duplicate calls and prove refusal/convergence;
7. enforce token, time, step, cost and effect budgets;
8. shadow or canary under an authority ceiling;
9. roll back and prove user recovery;
10. remove processes, ports, files, caches and synthetic records.

Passing means a reviewer can reproduce which version produced a proposal, which evidence supported it, why execution was allowed or denied and how recovery was proven.

## Reliability, security, observability, capacity, and cost

### Confusion-matrix arithmetic

```text
precision = TP / (TP + FP)
recall    = TP / (TP + FN)
F1        = 2 * precision * recall / (precision + recall)
```

For TP=72, FP=18 and FN=8:

```text
precision = 72/90 = 0.80
recall = 72/80 = 0.90
F1 ≈ 0.847
```

Acceptance depends on the cost of 18 unnecessary escalations versus eight missed dangerous changes. Report raw counts and slices, not only F1.

### Token budget

```text
available input =
  context limit
  - reserved output
  - fixed instructions and tool schemas
  - safety margin
```

With 16,000 context tokens, 2,000 output reserve, 2,500 fixed tokens and 1,000 margin, 10,500 remain for user input, history and retrieval. Define priority and truncation; silent tail-cutting can remove the question or decisive evidence.

### Retrieval quality

For labeled relevant set `E` and top-K retrieval `R`:

```text
recall@K = |E intersect R| / |E|
precision@K = |E intersect R| / K
```

If five passages are relevant and top ten contains four, recall@10=0.8 and precision@10=0.4. Generation cannot recover the missing fifth passage from its grounding context.

### Agent amplification

If each step allows two tool calls and retries each call three times, ten steps permit:

```text
10 * 2 * 3 = 60 tool attempts
```

Nested agents multiply further. Enforce a run-wide budget, not only per-tool retry. Measure completed verified tasks per call, token and currency unit.

### Reliability and recovery

Track availability separately from correctness and safe refusal. A safe refusal is success for an unsupported high-risk request. Useful signals include malformed output, unsupported claims, retrieval recall, tool refusal, duplicate effect, budget exhaustion, fallback success, rollback time and appeal resolution.

### Security and privacy

Prompts, retrieved content, outputs, embeddings, traces and evaluation sets are data copies with purpose, access, retention and deletion. Redact at source. Minimize tools. Validate output before any interpreter. Assume direct and indirect input can be hostile. Keep secrets outside prompts and model-visible observations.

### Capacity and cost

Split latency and spend into queue, retrieval, rerank, input/output tokens, inference, tools, review and retries. Cost per successful verified task is more useful than cost per token. Reserve fallback and rollback capacity; a cheap model that increases review and incidents may cost more overall.

## Traps and prevention

### Start with a model instead of a task

Prevention: write the decision, user, harm, abstention, non-AI baseline and acceptance gate first. Sometimes search, templates, rules or ordinary code win.

### Treat fluency as confidence

Prevention: verify facts and calculations independently. Require supported claims or abstention. Never derive authorization from tone or self-reported confidence.

### Put everything in context

Long input increases cost and distraction and can still hide evidence. Prevention: budget, select, order and test context under realistic positions; retain source identity.

### Call RAG grounded by default

Prevention: measure corpus coverage, parsing, retrieval recall, source freshness, claim support and citations independently.

### Defend injection with one instruction

Prevention: treat retrieved content as untrusted; keep identity, policy, authorization and execution outside the model; minimize tool capability.

### Let schema-valid calls execute

Schema proves shape, not permission or intent. Prevention: bind principal/tenant, authorize exact resource/action, approve consequential effects and validate resulting state.

### Retry a timed-out tool blindly

Prevention: stable operation ID, idempotency key, receipt lookup and reconciliation before retry.

### Use a model judge as truth

Prevention: calibrate on reviewed labels, inspect disagreements and slices, version judge/rubric and retain deterministic checks where possible.

### Say "human in loop" without designing the loop

Prevention: specify presented evidence, reviewer competence/time, veto, override, appeal, workload and effectiveness sampling.

### Log everything for observability

Prevention: minimize and redact prompts/content, use digests and IDs, classify copies, enforce retention/access/deletion and test incident usefulness.

## Memory card and retrieval

Remember **TASK — EVIDENCE — AUTHORITY — OUTCOME**:

```text
TASK: user, decision, harm, abstain, baseline, gate
EVIDENCE: data/split, tokens/context, retrieval, version, provenance
AUTHORITY: schema, identity, policy, approval, idempotency, budget
OUTCOME: verified effect, monitoring, appeal, rollback, learning
```

Say these aloud:

1. Token probability is not answer truth.
2. Context capacity is not effective context.
3. Similarity is not relevance.
4. Retrieval is not grounding.
5. A tool proposal is not authorization.
6. Human presence is not effective oversight.
7. A benchmark score is not production outcome.

## Complete answers

### What is a token and why should an SRE care?

A token is a tokenizer-specific unit mapped to an ID before model computation. It may be a word, subword, punctuation or byte sequence. Token count drives context admission, truncation, inference work, latency and often cost. Record tokenizer/version and counts per prompt component; never estimate a safety boundary from characters alone.

### Why does information inside the context still get missed?

The model does not query context like an indexed database. Position, distractors, wording and learned behavior affect use. Truncation may also remove text before inference. Test decisive evidence at beginning, middle and end with realistic noise, and use retrieval plus deterministic extraction when exact presence matters.

### What does RAG actually guarantee?

Nothing automatically end-to-end. It adds a retrieval path. A trustworthy claim needs authoritative and current corpus state, preserved parse/chunk identity, compatible embeddings, authorized filtering, sufficient recall, effective context placement, faithful generation and citation verification. Failure at any stage requires abstention or correction.

### How do you stop prompt injection?

Do not promise complete prevention through prompting. Prevent impact architecturally: classify all external content as data, separate instruction sources, minimize exposed tools, parse calls strictly, resolve identity outside the model, enforce current least-privilege authorization, require approval for consequences, sandbox where suitable, validate output/effects and audit. Test direct and indirect attacks continuously.

### What makes an AI tool safe?

A narrow purpose and closed schema; server-derived actor and tenant; allow-listed resources; current authorization; risk-based approval; bounded deadline/rate/cost; stable operation identity and idempotency; validated output and resulting state; privacy-safe audit; fallback and revocation. The model chooses none of these security facts.

### When is a human review effective?

When the reviewer sees decision-relevant evidence and uncertainty, understands the domain, has enough time, is not overloaded, can refuse or modify the action, and affected users can appeal. Measure override quality, missed harms, agreement, time and workload; otherwise "human in loop" is a label.

### How should AI output be tested?

Combine deterministic interface/schema/policy tests with a versioned held-out task set, edge/adversarial cases, critical population slices, cost-sensitive metrics, calibrated human/model judgments and monitored real outcomes. Compare a non-AI and previous-version baseline. Gate regressions and keep rollback.

## Product-company interview

### Design an AI assistant that proposes Kubernetes fixes

Start with advisory read-only scope. Define incidents, correct recommendation, dangerous recommendation, abstention and non-AI runbook baseline. Retrieve only authorized versioned runbooks and cluster evidence. Model output becomes a typed proposal with sources; deterministic Kubernetes schema/policy checks and a human review the diff. The system never gives the model cluster credentials. A separate least-privileged executor uses current identity, namespace, action allow-list, idempotency, deadline and audit. Begin shadow-only, evaluate by incident type, then canary low-risk reversible actions with rollback.

**Senior follow-up:** an alert or log line can contain injection text. It stays untrusted evidence and cannot select privileges or bypass approval.

### Offline evaluation rose 8 percent; ship?

Not from that fact. Inspect task/population, immutable candidate/baseline, split provenance and contamination, raw counts, uncertainty, critical slices, failure costs, latency/cost and security. Verify the metric predicts user outcome. Require deterministic regressions, adversarial tests, calibrated review, shadow/canary evidence and compatible rollback.

### Explain an agent loop safely

It is a durable state machine with run and step identity. The model proposes a plan or call; host code validates, authorizes, possibly requests approval, executes idempotently and returns a bounded observation. One end-to-end deadline and step/token/tool/cost/effect budgets cap amplification. Terminal states include completed, refused, budget-exhausted and needs-human. External state is reconciled before retry.

### A RAG answer cites a plausible but wrong policy

Freeze request, corpus/chunk/index/model/prompt versions. Verify authority and freshness, parsing, authorization filter, retrieval/rerank, context placement and claim-to-span support. Contain by abstaining or restoring known-good corpus/index. Add the case at the first failed stage and end-to-end, then fix ownership and freshness monitoring.

### Build versus buy an AI model service

Compare task quality and risk, data residency/retention, model/version control, context and tool interface, evaluation support, latency/capacity, outage/fallback, pricing and concentration, security/audit, portability and exit. A provider benchmark is not application evidence. Keep manifests and contract tests so replacements are measurable.

## Independent transfer and rubric

The learner receives an unseen synthetic AI-assisted system and evidence packet. They must define the task/baseline/harm, map model and data paths, find the first unsafe boundary, calculate evaluation/retrieval/token/agent budgets, contain an injected failure, design external authority controls, prove rollback and revise after a constraint change.

- **90–100:** complete identity/evidence chain, representative metrics, strict authority, reversible recovery and explicit uncertainty.
- **75–89:** safe plan with minor coverage or calculation gaps.
- **60–74:** useful concepts but one major evaluation, authority, privacy or recovery boundary is weak.
- **below 60:** trusts fluency, aggregate score or model self-review; allows broad tools; hides uncertainty; lacks cleanup.

Automatic failure: real credentials/data, shared service, unrestricted shell/network/admin tool, unbounded loop, fabricated evidence, unauthorized effect or missing teardown. Reading and the offline model do not award mastery.

## References and review

- [NIST AI RMF Core](https://airc.nist.gov/airmf-resources/airmf/5-sec-core/) — govern, map, measure and manage risk.
- [NIST Generative AI Profile](https://nvlpubs.nist.gov/nistpubs/ai/NIST.AI.600-1.pdf) — generative-AI risk treatment.
- [OWASP Top 10 for LLM Applications 2025](https://owasp.org/www-project-top-10-for-large-language-model-applications/assets/PDF/OWASP-Top-10-for-LLMs-v2025.pdf) — injection, disclosure, supply chain and agency threats.
- [Google classification metrics](https://developers.google.com/machine-learning/crash-course/classification/accuracy-precision-recall) and [bias evaluation](https://developers.google.com/machine-learning/crash-course/fairness/evaluating-for-bias) — cost-sensitive and sliced measurement.
- [Hugging Face tokenization pipeline](https://huggingface.co/docs/tokenizers/main/pipeline) — normalization through token IDs.
- [Attention Is All You Need](https://arxiv.org/abs/1706.03762) and [Sentence-BERT](https://arxiv.org/abs/1908.10084) — transformer and embedding foundations.
- [Retrieval-Augmented Generation](https://arxiv.org/abs/2005.11401), [ReAct](https://arxiv.org/abs/2210.03629) and [Toolformer](https://arxiv.org/abs/2302.04761) — retrieval, acting and tool-use research.
- [TruthfulQA](https://arxiv.org/abs/2109.07958), [HELM](https://arxiv.org/abs/2211.09110) and [Model Cards](https://arxiv.org/abs/1810.03993) — truthfulness, holistic evaluation and reporting.
- [Lost in the Middle](https://arxiv.org/abs/2307.03172) — evidence that nominal context capacity does not guarantee effective use.

Behavior, limits, interfaces and prices remain version-dependent. Research results are not universal product guarantees. The offline model proves only deterministic evidence ordering. Publication needs technical, instructional, security and source review; mastery needs representative runtime, independent transfer and delayed recall.
