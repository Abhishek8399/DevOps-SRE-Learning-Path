---
{
  "schemaVersion":1,
  "kind":"lesson",
  "id":"LES-0087",
  "slug":"devops-sre-platform-career-roadmaps",
  "aliases":["V10-L05","devops-sre-platform-career-roadmaps"],
  "curriculumIds":["CAR-001"],
  "route":"/book/architecture/devops-sre-platform-career-roadmaps",
  "order":5,
  "volume":"10-architecture-leadership",
  "title":"DevOps, SRE, platform, cloud, infrastructure, data-platform and architect career roadmaps",
  "summary":"Turn versioned role requirements and truthful learner-owned evidence into dependency-aware, capacity-bounded roadmaps with practical milestones, failure work, independent review, specialist branches and explicit limits on level and hiring claims.",
  "domain":"career-development",
  "level":{"from":"foundation","to":"expert"},
  "estimatedMinutes":600,
  "prerequisiteLessonIds":["LES-0086"],
  "prerequisiteCurriculumIds":["INT-002"],
  "testedEnvironments":[
    {"platform":"Workforce and career frameworks","version":"SFIA 9, NIST NICE, OPM and public GitLab guidance reviewed 2026-08-07","support":"concept-only","notes":"Frameworks provide vocabularies and examples; titles and levels remain organization-specific and no learner level is inferred."},
    {"platform":"DevOps, SRE, cloud and platform sources","version":"CNCF, DORA, Google SRE, Microsoft Learn and AWS sources reviewed 2026-08-07","support":"concept-only","notes":"Sources describe practices or published task domains; they do not prove production experience or hiring readiness."},
    {"platform":"Ubuntu","version":"24.04 WSL UID-1000 guarded lifecycle","support":"required","notes":"All 73 cases, six calculations, authority/root/unknown-artifact refusal and exact cleanup pass."},
    {"platform":"Learner, employer or cloud system","version":"not present in the tested boundary","support":"unsupported","notes":"No resume, candidate record, assessment system, provider credential, application, message, level judgment or hiring prediction is accessed or produced."}
  ],
  "targetRoles":["devops-engineer","site-reliability-engineer","platform-engineer","cloud-engineer","infrastructure-engineer","production-engineer","data-platform-engineer","technical-lead","staff-engineer","solutions-architect"],
  "learningObjectives":[
    "Separate job title, responsibility, competency, evidence, credential, organizational maturity and hiring decision.",
    "Translate versioned role descriptions into tasks, knowledge, skills, operating context, responsibility signals and honest unknowns.",
    "Inventory learner-owned evidence by provenance, permission, recency, environment, independence and proof limit without inferring level.",
    "Build a dependency graph from systems and networking through software, delivery, reliability, platforms, security, data and architecture.",
    "Plan finite weekly and quarterly capacity with fixed work, focused practice, review, recovery reserve and explicit stopped work.",
    "Define milestones as artifacts, explanation, failure injection, recovery, cleanup, review and delayed unfamiliar transfer rather than reading completion.",
    "Use one evolving production-shaped local service to connect technical domains without misrepresenting local fixtures as production.",
    "Construct role-specific junior, mid, senior, lead, staff and architect responsibility hypotheses without universalizing titles.",
    "Build DevOps, SRE, cloud, infrastructure, platform and data-platform branches while preserving a shared foundation.",
    "Revise roadmaps from evidence and changing constraints while preserving decision history, confidentiality and non-mastery boundaries."
  ],
  "productionSignals":[
    "A plan lists popular tools but cannot name the work operations or failure mechanisms they support.",
    "Course, repository or certification completion is treated as proof of production competence.",
    "A senior or architect title is selected from years of experience or self-rating alone.",
    "Kubernetes, SLOs or architecture work starts before Linux, networking, state and user-operation prerequisites.",
    "Planned hours exceed real capacity, leave no recovery reserve and hide stopped work.",
    "Milestones accept reading or happy-path deployment without failure, recovery, explanation or reviewer evidence.",
    "A local fixture or design is described as production, on-call, cloud-provider or organizational experience.",
    "One generic roadmap erases material differences among SRE, platform, cloud, private-cloud and data-platform work.",
    "A changed role or personal constraint overwrites the old plan and its decision rationale.",
    "Private employer evidence, AI-invented experience, learner scoring or hiring prediction enters the roadmap system."
  ],
  "diagrams":[
    {"id":"LES-0087-DIA-001","title":"Role-to-roadmap evidence loop","direction":"cyclic","boundaries":["versioned role","work and responsibility map","learner-owned evidence","gap and dependency graph","capacity-bounded milestones","independent transfer","reviewed revision"],"evidencePoints":["source/date","task/skill/scope","provenance/permission","missing/stale/adjacent","artifact/fault/acceptance","review receipt","versioned diff"],"textAlternative":"A versioned role becomes work and responsibility requirements, which are compared with permitted evidence; gaps and dependencies form finite milestones, independent transfer reveals weaknesses, and a versioned revision closes the loop without inventing capability."},
    {"id":"LES-0087-DIA-002","title":"Shared foundation and specialist branches","direction":"hierarchical","boundaries":["systems and networking","software and automation","delivery and reliability","cloud/SRE/platform/private-cloud/data branches","leadership and architecture"],"evidencePoints":["diagnostic receipts","tested tool","release/recovery","role-specific project","cross-system decision"],"textAlternative":"Linux, networking, software, delivery and reliability form a shared trunk; cloud, SRE, platform, private-cloud and data-platform deepen as separate branches before leadership and architecture integrate broader responsibility."},
    {"id":"LES-0087-DIA-003","title":"Evidence strength ladder","direction":"bottom-to-top","boundaries":["reading","guided reproduction","independent bounded work","changed-constraint transfer","representative authorized operation","longitudinal outcome"],"evidencePoints":["completion","fixture receipt","reviewer observation","unfamiliar fault","production authority","repeatable result"],"textAlternative":"Evidence strengthens from reading through guided and independent practice, unfamiliar transfer, authorized representative operation and longitudinal outcomes; lower rungs remain useful but cannot be relabeled as higher ones."},
    {"id":"LES-0087-DIA-004","title":"Finite capacity control loop","direction":"cyclic","boundaries":["available hours","fixed commitments","focus work","review and recovery reserve","observed throughput","stopped work","replan"],"evidencePoints":["calendar constraint","non-negotiable load","work-in-progress limit","reserve percentage","completed receipts","deferred milestone","new version"],"textAlternative":"Available hours are reduced by fixed commitments and protected reserve before focus work is accepted; observed throughput and explicit stopped work drive replanning rather than overtime fiction."},
    {"id":"LES-0087-DIA-005","title":"Milestone acceptance stack","direction":"bottom-to-top","boundaries":["concept explanation","working artifact","fault injection","safe recovery","cleanup proof","independent review","delayed transfer"],"evidencePoints":["teach-back","tests/output","first failing signal","restored invariant","absence receipt","rubric anchors","unfamiliar context"],"textAlternative":"A milestone grows from explanation to artifact, bounded fault, verified recovery, cleanup, independent review and delayed unfamiliar transfer; course completion alone never closes the stack."},
    {"id":"LES-0087-DIA-006","title":"Responsibility expansion cone","direction":"hierarchical","boundaries":["bounded task","service ownership","multi-service coordination","cross-team mechanism","portfolio strategy"],"evidencePoints":["guided execution","independent operation","ambiguous trade-off","organizational leverage","decision system"],"textAlternative":"Responsibility expands from bounded execution through service ownership, cross-service and cross-team mechanisms to portfolio strategy; titles are hypotheses and each wider scope requires observable authority, complexity, influence and outcomes."}
  ],
  "commands":[
    {"id":"LES-0087-CMD-001","question":"Is this an offline fictional roadmap shell?","risk":"read-only","command":"bash lab.sh doctor","runFrom":"LES-0087 support/lab as a normal Ubuntu user","expectedBranches":[{"when":"doctor=pass","meaning":"dependencies and authority/privacy guards pass","nextEvidence":"initialize bounded fixture state"},{"when":"lab=fail","meaning":"a prerequisite or safety boundary failed","nextEvidence":"correct it without bypass"}],"proves":"local prerequisites and refusal gates","doesNotProve":"learner capability, level or hiring probability"},
    {"id":"LES-0087-CMD-002","question":"Can exact fictional state initialize?","risk":"mutating-bounded","command":"bash lab.sh setup","runFrom":"LES-0087 support/lab","expectedBranches":[{"when":"setup=pass","meaning":"one UID-scoped allowlisted state exists","nextEvidence":"inspect identity"},{"when":"refusal","meaning":"ownership, prior state or authority is unsafe","nextEvidence":"preserve the refusal"}],"proves":"bounded initialization","doesNotProve":"access to a learner, employer or provider","cleanup":"Run bash lab.sh cleanup."},
    {"id":"LES-0087-CMD-003","question":"Is the intended roadmap packet loaded?","risk":"read-only","command":"bash lab.sh status","runFrom":"LES-0087 support/lab after setup","expectedBranches":[{"when":"cases=73 and packet identity matches","meaning":"fixture identity is established","nextEvidence":"inspect boundaries"}],"proves":"fixture identity","doesNotProve":"the packet describes a learner"},
    {"id":"LES-0087-CMD-004","question":"Which unsafe roadmap boundaries are modeled?","risk":"read-only","command":"bash lab.sh roadmap","runFrom":"LES-0087 support/lab after setup","expectedBranches":[{"when":"roadmap=pass","meaning":"nineteen boundary groups are listed","nextEvidence":"challenge individual cases"}],"proves":"declared model coverage","doesNotProve":"all real career risks are covered"},
    {"id":"LES-0087-CMD-005","question":"Are fictional role requirements versioned and mapped?","risk":"read-only","command":"bash lab.sh roles","runFrom":"LES-0087 support/lab after setup","expectedBranches":[{"when":"coverage_pct=100.00 and stale=0","meaning":"all 48 fixture requirements resolve across nine versioned roles","nextEvidence":"human source and relevance review"}],"proves":"fixture mapping arithmetic","doesNotProve":"current vacancy status or learner fit"},
    {"id":"LES-0087-CMD-006","question":"How strong is the fictional evidence inventory?","risk":"read-only","command":"bash lab.sh evidence","runFrom":"LES-0087 support/lab after setup","expectedBranches":[{"when":"total=60 and attributable_pct=80.00","meaning":"48 claims are attributable and twelve remain explicit gaps","nextEvidence":"retain gaps rather than infer a level"}],"proves":"fixture conservation","doesNotProve":"real evidence truth or quality"},
    {"id":"LES-0087-CMD-007","question":"Does the prerequisite graph close without cycles?","risk":"read-only","command":"bash lab.sh dependencies","runFrom":"LES-0087 support/lab after setup","expectedBranches":[{"when":"coverage_pct=100.00 and cycles=0","meaning":"all 52 fixture edges resolve","nextEvidence":"review pedagogical and learner-specific ordering"}],"proves":"fixture graph integrity","doesNotProve":"one universal learning order"},
    {"id":"LES-0087-CMD-008","question":"Does planned work conserve finite capacity and reserve?","risk":"read-only","command":"bash lab.sh capacity","runFrom":"LES-0087 support/lab after setup","expectedBranches":[{"when":"committed_pct=80.00 and reserve_pct=20.00","meaning":"520 fictional annual hours conserve","nextEvidence":"replace with actual learner-authorized constraints"}],"proves":"fixture capacity arithmetic","doesNotProve":"health, motivation or future availability"},
    {"id":"LES-0087-CMD-009","question":"Are milestones evidence-shaped rather than reading-only?","risk":"read-only","command":"bash lab.sh milestones","runFrom":"LES-0087 support/lab after setup","expectedBranches":[{"when":"structure_pct=100.00 and reading_only=0","meaning":"all 24 fixture milestones contain declared fields","nextEvidence":"perform and review real work"}],"proves":"fixture structure","doesNotProve":"milestone completion or competence"},
    {"id":"LES-0087-CMD-010","question":"Are reviews independent and free of hiring predictions?","risk":"read-only","command":"bash lab.sh reviews","runFrom":"LES-0087 support/lab after setup","expectedBranches":[{"when":"independent_pct=100.00 and hiring_predictions=0","meaning":"all 16 fixture reviews preserve the boundary","nextEvidence":"run reviewer-owned unfamiliar work"}],"proves":"fixture review classification","doesNotProve":"reviewer quality or learner transfer"},
    {"id":"LES-0087-CMD-011","question":"Can course completion be treated as competence?","risk":"read-only","command":"bash lab.sh evaluate course-completion-equals-skill","runFrom":"LES-0087 support/lab after setup","expectedBranches":[{"when":"boundary=course-credential","meaning":"completion remains exposure evidence only","nextEvidence":"define artifact, failure and independent transfer"}],"proves":"planned evidence boundary","doesNotProve":"what the learner retained"},
    {"id":"LES-0087-CMD-012","question":"Do all gates, calculations, refusals and cleanup pass?","risk":"mutating-bounded","command":"bash verify.sh","runFrom":"LES-0087 support/lab from absent state","expectedBranches":[{"when":"verify=pass","meaning":"73 cases, six calculations, refusals and cleanup pass","nextEvidence":"retain non-evaluative limits"},{"when":"failure","meaning":"candidate lab evidence is rejected","nextEvidence":"preserve the first failed gate"}],"proves":"guarded offline lifecycle","doesNotProve":"learner level, readiness, mastery or hiring outcome","cleanup":"Verifier proves exact UID-scoped state absence."}
  ],
  "labs":[
    {"id":"LES-0087-LAB-001","title":"Guided evidence-based roadmap review","mode":"guided","environment":"Ubuntu 24.04 normal user with Bash and Python 3; fictional local JSON only","timeMinutes":240,"privilege":"normal user; root, candidate, resume, employer, cloud, AI-service and production authority refused","network":"none","changes":["one UID-scoped temporary root","copied fictional cases and roadmap packet"],"abortConditions":["root","credential","candidate or people-system authority","private resume, portfolio or recording path","cloud or production endpoint","symlink","wrong owner","unknown artifact"],"recovery":"Preserve the first failed assertion and remove only exact allowlisted state.","cleanupProof":"Exact inventory followed by state-root absence.","path":"drafts/LES-0087-devops-sre-platform-career-roadmaps/support/lab"},
    {"id":"LES-0087-LAB-002","title":"Independent two-role roadmap defense and revision","mode":"independent","environment":"Reviewer-owned current role descriptions, canonical curriculum graph and learner-owned policy-safe evidence","timeMinutes":360,"privilege":"learner and reviewer only; reviewer owns hidden role differences, constraint changes, scorecards and delayed follow-up","network":"none","changes":["local role maps","evidence and gap ledgers","capacity budgets","milestones","review receipts","versioned revisions"],"abortConditions":["confidential artifact","credential or endpoint","fabricated evidence","level inference","hiring prediction","answer-key exposure","unauthorized AI or recording"],"recovery":"Withdraw unsupported claims, preserve the roadmap diff and sanitize or discard prohibited material.","cleanupProof":"Reviewer confirms no prohibited data, secret, answer key, level judgment or hiring prediction remains.","path":"drafts/LES-0087-devops-sre-platform-career-roadmaps/support/lab"}
  ],
  "incidents":[
    {"id":"LES-0087-INC-001","signal":"A learner completes ten courses and the roadmap marks senior SRE achieved.","firstThought":"Consumption was converted into responsibility without transfer evidence.","safePath":"Restore the level to unknown, map the target work and require artifacts, faults, independent review and representative evidence.","trap":"Add more course certificates."},
    {"id":"LES-0087-INC-002","signal":"A twelve-month plan contains twenty hours of weekly work although only eight hours are available.","firstThought":"The plan violates capacity before learning begins.","safePath":"Protect reserve, rank dependencies, reduce work in progress and record stopped milestones.","trap":"Assume permanent overtime."},
    {"id":"LES-0087-INC-003","signal":"A local Kubernetes exercise is described in a portfolio as operating a large production platform.","firstThought":"Environment and authority were inflated.","safePath":"State the exact local topology, tested fault and proof limit; retain production operation as a gap.","trap":"Use enterprise language without evidence."},
    {"id":"LES-0087-INC-004","signal":"One generic roadmap gives identical milestones to public-cloud SRE, private-cloud infrastructure and data-platform roles.","firstThought":"Tool overlap erased different state, failure and responsibility models.","safePath":"Keep the shared foundation, then branch by actual role operations, environments and evidence.","trap":"Add every specialist tool to one path."},
    {"id":"LES-0087-INC-005","signal":"A changed job description causes the old roadmap and missed assumptions to be overwritten.","firstThought":"The learning decision history was destroyed.","safePath":"Freeze the new source, create a diff, state the trigger and preserve completed, invalidated, deferred and new work.","trap":"Rewrite history so the plan appears accurate."}
  ],
  "assessmentIds":["ASM-0244","ASM-0245","ASM-0246"],
  "referenceIds":["REF-1082","REF-1083","REF-1084","REF-1085","REF-1086","REF-1087","REF-1088","REF-1089","REF-1090","REF-1091","REF-1092","REF-1093","REF-1094","REF-1095","REF-1096","REF-1097","REF-1098","REF-1099"],
  "contentStatus":"substantive-draft",
  "masteryBoundary":"publication-does-not-award-mastery",
  "lastReviewed":"2026-08-07",
  "reviewAfter":"2027-02-07",
  "limitations":[
    "This quarantined candidate teaches roadmap construction; it contains no learner profile, accepted career decision, employer evaluation, promotion or hiring prediction.",
    "All roles, requirements, evidence, hours, milestones, reviews and scores in the lab are fictional.",
    "Public frameworks, career pages and certification guides are contextual inputs, not universal titles, current vacancies or proof of job performance.",
    "Automated structure and arithmetic cannot establish competence, responsibility, health, opportunity, readiness, level or employment outcome.",
    "No resume, ATS, people system, cloud provider, production endpoint, application, message, recording or AI service is accessed.",
    "Formal technical, security, privacy, accessibility, legal/policy, career-development, instructional and assessment review plus learner-owned evidence and delayed independent transfer remain required."
  ]
}
---

# DevOps, SRE, platform, cloud, infrastructure, data-platform and architect career roadmaps

## What you see and first thought

You open several job descriptions. One asks for Linux, Python, AWS, EKS, Terraform, GitLab and Splunk. Another asks for Kubernetes, OpenStack, Ceph, KVM, networking and Jenkins. A third adds Spark, Airflow, Cassandra and ML platforms. The natural reaction is to create a giant list:

> Linux in week one, networking in week two, Python in week three, Docker in week four, Kubernetes in month two, three clouds in month three, then Terraform, Jenkins, security, databases, system design and certifications. After that I will be a senior SRE.

Whenever you see a roadmap like this, do not ask whether the list is long enough. Ask: **what observable work will become possible, which prerequisite makes it possible, and what evidence will survive an unfamiliar failure?**

A tool list is an inventory. A career roadmap is a versioned decision system. It connects:

```text
target work
  -> responsibility expected
  -> evidence already permitted and available
  -> honest gap
  -> prerequisite
  -> capacity-bounded milestone
  -> artifact + fault + recovery + explanation
  -> independent review
  -> delayed transfer
  -> revised plan
```

That distinction protects you from two expensive errors. The first is **shallow breadth**: touching twenty products while remaining unable to trace one failed request. The second is **false seniority**: treating time, courses or confidence as proof that you can own ambiguous production outcomes.

### The first mental correction

Do not begin with “Which title am I?” Titles are organization-specific labels. Begin with “Which work can I currently demonstrate, under what conditions, with which authority and evidence?” Then compare that evidence with a versioned target role.

This chapter will describe foundation, junior, mid-level, senior, lead, staff and architect **responsibility hypotheses**. They are navigation aids, not judgments about you. A company may call independent service ownership “Engineer II,” “Senior,” “SRE” or something else. SFIA similarly separates responsibility levels from job titles and warns that role profiles require local tailoring. The lesson therefore scores roadmap structure, never a person.

### Three columns that prevent self-deception

For every target capability, keep three columns:

| Required work | Current evidence | Gap or next evidence |
|---|---|---|
| diagnose Linux storage exhaustion | guided inode lab; command reasoning explained; independent remediation pending | reviewer-owned changed-path incident, safe cleanup and delayed recall |
| operate Kubernetes production workloads | local cluster exercises only | representative authorized operations remain missing |
| design reliable delivery | tested local pipeline and rollback fixture | unfamiliar stateful migration and independent review |

The wording matters. “Local cluster exercises only” is not failure. It is useful evidence with an honest environment boundary. The roadmap can now select the next task without inflating it into production experience.

### What you should refuse

Refuse a roadmap that:

- declares your level from a self-rating, résumé title, years or repository count;
- promises a job, promotion or organizational dependence;
- converts a certification into production capability;
- copies private employer, customer or colleague data;
- asks for provider credentials merely to teach concepts locally;
- schedules more hours than exist;
- makes every topic simultaneous priority;
- calls reading a completed operational milestone;
- hides failures or removes cleanup;
- uses AI-generated experience as personal evidence.

The correct outcome is not “companies should depend on one person.” Healthy systems reduce key-person risk. The durable professional advantage is becoming someone trusted to make ambiguous systems more understandable, safer and easier for others to operate.

### What completion means

Completing this chapter proves that the repository contains a roadmap method. Passing the lab proves that fictional records satisfy declared structure, arithmetic, refusal and cleanup rules. Neither proves your level, readiness or employability.

Stronger evidence arrives when you use learner-owned, policy-safe material; a reviewer selects an unfamiliar role and hidden constraint; you construct and defend a plan; and a later changed context shows transfer. Even then, the receipt describes that exercise. An employer retains its own decision authority.

## Terms before commands

Words such as “skill,” “senior” and “project” are too ambiguous to build a safe plan until they receive operational meanings.

### Job, role, title and role family

A **job** is a specific position in an organization at a time. Its source can expire.

A **role** is a set of expected outcomes, responsibilities and working relationships. One job may combine several roles.

A **title** is an organizational label. Never compare titles without comparing actual work.

A **role family** groups related work, such as infrastructure, SRE, platform or data platform. Families overlap. SRE may include software engineering, operations and reliability design; platform engineering may include product thinking, APIs, infrastructure and developer experience.

### Requirement and operating context

A **requirement** is source wording about expected work, knowledge, experience or qualification. Record whether it is required, preferred or contextual.

**Operating context** describes where the work happens: public cloud, private cloud, regulated payments, on-premises GPU fleet, globally distributed SaaS, data platform or internal developer platform. The same tool implies different responsibilities in different contexts.

“Kubernetes required” is incomplete without questions such as:

- Are you consuming or operating the control plane?
- Managed cloud or on-premises?
- How many clusters and failure domains?
- Stateful or stateless workloads?
- Who owns upgrades, networking, policy and incident response?
- Which availability and security constraints matter?

### Task, knowledge, skill and competency

A **task** is observable work: diagnose a failed rollout, restore a database, write a Terraform module or define an SLO.

**Knowledge** is information and mental models required to reason: TCP state, Linux virtual memory, consistency or identity semantics.

A **skill** is the practiced ability to perform an activity.

A **competency** integrates knowledge and skill in context to produce an outcome. Workforce frameworks use related terms differently, so preserve the selected source’s definition.

### Responsibility dimensions

Responsibility cannot be reduced to “knows more tools.” Useful dimensions are:

- **autonomy**: how much guidance is required;
- **scope**: task, component, service, platform, portfolio or organization;
- **complexity**: how ambiguous, coupled and novel the work is;
- **influence**: who must understand or adopt the decision;
- **impact**: which user, risk or business outcome changes;
- **authority**: which decisions the person is permitted to make;
- **accountability**: which result or closure path they own.

A person can be advanced in Linux diagnosis and foundational in organizational strategy. Capability profiles are multidimensional.

### Evidence and proof limit

**Evidence** supports or challenges a claim. Its **proof limit** states what it cannot establish.

Examples:

- A passed unit test proves the tested behavior under its inputs; it does not prove production reliability.
- A local Kubernetes incident proves bounded diagnostic work; it does not prove operating a multi-region fleet.
- A certification proves performance under a versioned exam contract; it does not prove an employer-specific role.
- A production change record may support authorized experience, but confidentiality may forbid public disclosure.

### Evidence classes

Use:

- **observed**: directly supported by a permitted artifact or reviewer;
- **calculated**: derived from recorded inputs and formula;
- **qualified**: partly supported with an explicit boundary;
- **missing**: required evidence is not present;
- **stale**: evidence may no longer reflect current tools or responsibility;
- **prohibited**: evidence exists but cannot be used in this context;
- **adjacent**: a related mechanism is known, but transfer remains unproved.

Missing and prohibited are different. A prohibited employer artifact cannot be “fixed” by copying it into the roadmap.

### Prerequisite and dependency

A **prerequisite** is a capability that materially lowers the risk or cognitive load of later work. A **dependency edge** explains why:

```text
Linux process and filesystem state
  -> container isolation and resource diagnosis
  -> Kubernetes workload lifecycle
  -> platform scheduling and multi-tenancy
```

Dependencies are not absolute school grades. You can preview later ideas, but independent operational claims require the supporting mechanism.

### Milestone, artifact and acceptance

A **milestone** is a bounded outcome with acceptance evidence. “Complete Kubernetes” is not bounded.

An **artifact** is a reviewable result: code, test, manifest, diagram, runbook, incident timeline, recovery receipt or decision record.

**Acceptance** states what must be observed, by whom, under which conditions. Good acceptance includes explanation, a changed constraint, cleanup and proof limits.

### Guided, independent and representative work

**Guided work** exposes mechanisms with known instructions.

**Independent work** hides part of the path or answer and is controlled by a reviewer.

**Representative work** resembles the authority, scale, state and consequences of the target environment. Local simulations are valuable but not automatically representative.

### Transfer and delayed transfer

**Transfer** is using a model in an unfamiliar context. **Delayed transfer** tests whether the capability remains available after time has passed. Repeating the same lab immediately measures recall and rehearsal more than durable transfer.

### Credential and certification

A **credential** is an attestation issued under a defined policy. A **certification** generally evaluates a published domain and has a version, rules and sometimes expiry. Record the exact current contract. Treat it as one evidence source, not as a substitute for hands-on work.

### Capacity, reserve and stopped work

**Capacity** is the finite time and energy available after fixed commitments.

**Reserve** protects review, unexpected difficulty, health and recovery. It is not “wasted time.”

**Stopped work** is a deliberate decision not to begin or continue something. If every topic is priority, priority has not happened.

### Roadmap version and decision record

A roadmap version preserves inputs, assumptions, selected work, rejected alternatives, capacity and date. A **decision record** explains why a change was made. Never rewrite the old plan to appear correct.

### Practice score, level and hiring outcome

A **practice score** is an observation against a rubric in one exercise.

A **level** is an organization-specific judgment about responsibility.

A **hiring outcome** belongs to an employer’s authorized process. This repository produces neither of the last two.

## Architecture map

The six diagrams form one operating model. Each arrow is a place where a roadmap can become dishonest or unexecutable.

### Diagram 1 — role-to-roadmap evidence loop

```text
[versioned role] -> [work + responsibility] -> [permitted evidence]
       ^                                           |
       |                                           v
[reviewed revision] <- [transfer receipt] <- [gaps + dependencies]
       ^                                           |
       +-------- [capacity-bounded milestones] <---+
```

Freeze the role before mapping it. Translate wording into work and responsibility without erasing explicit vendor requirements. Compare against evidence. Gaps plus dependencies select milestones. Independent transfer produces observations. Revision returns to the source rather than inventing readiness.

If a reviewer finds weak networking reasoning, do not merely add “advanced networking” to the list. Identify the missing operation—perhaps tracing asymmetric routing or explaining TLS identity—and design a bounded artifact and failure that exposes it.

### Diagram 2 — shared foundation and specialist branches

```text
                    [leadership + architecture]
                              |
       +----------+-----------+-----------+----------+
       |          |                       |          |
     [SRE]    [cloud/DevOps]          [platform] [data/private cloud]
       \          |                       |          /
        +---------+---- [delivery + reliability] ---+
                          |
                 [software + automation]
                          |
                 [Linux + networking]
```

This is a dependency tree, not a hierarchy of human value. Linux and networking help because containers, clusters, clouds, databases and pipelines ultimately run through processes, files, names, routes, sockets and state. Software and automation make diagnosis repeatable. Delivery and reliability connect change to user outcomes. Branches then deepen different state and failure models.

### Diagram 3 — evidence strength ladder

```text
          [longitudinal outcome]
       [representative authorized work]
          [unfamiliar transfer]
        [independent bounded work]
          [guided reproduction]
               [reading]
```

Every rung has value. The error is relabeling it. Reading builds vocabulary. Guided reproduction exposes a mechanism. Independent work reveals whether you can choose the path. Unfamiliar transfer tests generalization. Representative authorized work adds realistic authority and consequence. Longitudinal outcomes show repeatability.

You do not need to wait for a production job before learning. You do need to tell the truth about which rung your evidence occupies.

### Diagram 4 — finite capacity control loop

```text
[available hours] -> [fixed commitments] -> [protected reserve]
        ^                                      |
        |                                      v
     [replan] <- [observed throughput] <- [focus work]
        ^                                      |
        +------------- [stopped work] <--------+
```

Capacity protects depth. Suppose ten hours per week are sustainable. Five are fixed learning maintenance and review, three are new focus work and two are reserve. Scheduling fourteen hours does not create four hours; it creates hidden failure.

### Diagram 5 — milestone acceptance stack

```text
             [delayed unfamiliar transfer]
                 [independent review]
                    [cleanup proof]
                    [safe recovery]
                    [bounded fault]
                    [working artifact]
                  [concept explanation]
```

The stack is intentionally demanding for consequential skills. Not every small lesson needs every layer, but a claim such as “can operate Kubernetes” cannot close at concept explanation or happy-path deployment.

### Diagram 6 — responsibility expansion cone

```text
              / portfolio strategy \
             / cross-team mechanism  \
            / multi-service decision  \
           / independent service work  \
          / bounded guided operation    \
         /_______________________________\
```

Wider responsibility usually brings more ambiguity, coordination and consequence. It does not mean the person types every command. Senior and staff evidence often appears in decision systems, standards, delegation, prevention and organizational learning—while technical depth remains necessary for sound judgment.

## Request or state path

A roadmap should transform inputs through explicit state, not emerge from enthusiasm.

### Stage 1 — freeze the target

Record organization, public source or authorized document, retrieval date, title, location, stated experience, required and preferred items, operating context and unknowns. Give the snapshot an ID such as `ROLE-SRE-2026-08-v1`.

Never assume a posting remains open or unchanged. Its continuing value is as a versioned example of work requirements.

### Stage 2 — normalize requirements

For each requirement, record:

- exact source wording;
- durable work operation;
- task, knowledge and skill elements;
- environment or vendor constraint;
- responsibility hypothesis;
- evidence type that could support it;
- dependencies;
- uncertainty.

“Terraform” may normalize into modelling desired state, module interfaces, state ownership, plan review, drift, provider behavior, change authorization and recovery. Do not remove Terraform from the row if the role explicitly requires it.

### Stage 3 — inventory evidence

Use only learner-owned and policy-safe evidence. Record source, environment, date, authority, independence, result and proof limit. Do not copy a private repository merely to strengthen the plan.

The inventory is not a résumé draft. It may contain honest statements such as:

- guided only;
- local environment;
- observed once;
- explanation unreviewed;
- production evidence prohibited;
- unknown;
- stale version;
- no recovery test.

### Stage 4 — create the gap ledger

Compute no magical readiness percentage. A missing critical prerequisite can matter more than ten low-risk completed rows. Classify gaps:

- foundational mechanism;
- required product or environment;
- operational responsibility;
- scale or performance;
- security or compliance;
- communication or leadership;
- representative evidence;
- recency;
- disclosure.

### Stage 5 — build the dependency subgraph

Select only the curriculum paths needed by the role and current gap. Preserve edges. A public-cloud SRE path and private-cloud infrastructure path share a trunk but diverge.

### Stage 6 — allocate capacity

Begin with actual sustainable hours. Subtract fixed work, maintenance and protected reserve. Limit work in progress. Record what will not be attempted this cycle.

### Stage 7 — define evidence-shaped milestones

Every material milestone states:

- outcome;
- prerequisite;
- artifact;
- bounded fault or changed constraint;
- recovery and cleanup;
- explanation;
- security and cost boundary;
- reviewer;
- acceptance;
- proof limit;
- review date.

### Stage 8 — perform and preserve receipts

Run the work. Keep tests, outputs, diagrams, decisions and reviewer observations. A green script proves its contract only. Do not change the acceptance after seeing the result.

### Stage 9 — test unfamiliar transfer

The reviewer changes a path, requirement, fault, resource limit or role context. The learner has no answer key. Score observable work and preserve critical boundaries.

### Stage 10 — revise without rewriting history

Create a new roadmap version. Mark work retained, invalidated, deferred, added or stopped. Record the trigger and consequence. A plan that never changes is probably not reading evidence.

## Failure zoom

### Failure 1 — title before work

The plan begins “Become Staff Engineer in twelve months.” It then searches for activities that sound staff-level.

**Why it fails:** the title has replaced a versioned organizational responsibility model. Time cannot guarantee opportunity, authority or cross-team scope.

**Repair:** select target work and responsibility hypotheses. Build evidence for broader ambiguity, influence and durable mechanisms. Let an authorized organization decide its title.

### Failure 2 — course completion becomes competence

A dashboard marks Kubernetes complete after videos and a guided deployment.

**Why it fails:** exposure and reproduction have been promoted across several evidence rungs. No unfamiliar failure, recovery, state reasoning or independent review exists.

**Repair:** retain the course receipt as reading/guided evidence. Add an artifact, hidden fault, safe recovery, explanation and delayed transfer.

### Failure 3 — certifications become production experience

The résumé says “production AWS operations” because an associate exam passed.

**Why it fails:** the exam has a published scope and controlled assessment, while production includes organizational authority, real state, incidents and consequences.

**Repair:** state the exact credential and version. Keep cloud production evidence missing until authorized representative work exists.

### Failure 4 — breadth destroys depth

The learner studies AWS, Azure, GCP, OpenStack, Kubernetes, Spark, security and Go simultaneously.

**Why it fails:** context switching consumes capacity, prerequisite edges are skipped and no artifact becomes deep enough to defend.

**Repair:** choose one target branch, keep a shared foundation, limit active milestones and explicitly stop the rest for this cycle.

### Failure 5 — the roadmap violates arithmetic

Eight available hours contain twelve hours of new work, four hours of review and no reserve.

**Why it fails:** the plan is impossible before execution. The hidden remediation becomes overtime, skipped review or dishonest completion.

**Repair:** subtract fixed commitments and reserve first. Reduce scope. Capacity is a design input, not a motivation test.

### Failure 6 — the happy path closes the milestone

A service deploys once, so delivery is marked complete.

**Why it fails:** deployment success says little about artifact identity, partial failure, incompatible state, rollback, observability or cleanup.

**Repair:** inject a bounded failure, state expected first signal, recover, verify the user operation and prove cleanup.

### Failure 7 — local becomes production

A three-node local cluster is described as “operated enterprise Kubernetes.”

**Why it fails:** scale, tenancy, authority, organizational coordination and consequences were invented.

**Repair:** say “local three-node exercise,” name the fault and receipt, and list production operations as an evidence gap.

### Failure 8 — one path serves every role

The same milestones are assigned to an AWS SRE, NVIDIA-style on-premises platform engineer and data-platform operator.

**Why it fails:** overlap in Linux or Kubernetes hides different control planes, state, hardware, data, on-call and governance.

**Repair:** keep common dependencies and create role-specific branches from current requirement maps.

### Failure 9 — evidence quantity becomes readiness percentage

Forty-eight of sixty rows contain evidence, so the system declares 80% ready.

**Why it fails:** requirements have different criticality and evidence strengths. The 80% is only fixture attribution arithmetic.

**Repair:** show coverage and gaps without deriving a hiring or level score. Apply critical prerequisites and human review.

### Failure 10 — old plans disappear

A new job description causes every old milestone to be rearranged without a diff.

**Why it fails:** decisions, invalidated assumptions and real progress become unrecoverable.

**Repair:** preserve both role versions and create a roadmap decision record: trigger, retained work, invalidated work, new work, stopped work and consequence.

### Failure 11 — portfolio pressure creates fiction

The plan requires an impressive metric before evidence exists, so a percentage is estimated after the fact.

**Why it fails:** the output target corrupts the evidence system.

**Repair:** define the measurement before work, retain inputs and guardrails, or use a bounded qualitative result. Never backfill precision.

### Failure 12 — AI selects a level

An AI reads a résumé and announces “senior/staff ready.”

**Why it fails:** the model lacks organizational authority, complete context, representative observation and a valid decision contract.

**Repair:** use AI only to organize sanitized inputs or challenge a plan. A human reviewer observes work; an employer decides its level.

## Internals and state ownership

A career-roadmap repository needs separate records because each state has a different owner and change trigger.

### Role source record

Owns organization, source, retrieval date, title, wording, context, unknowns and expiry. It never owns claims about the learner.

### Requirement record

Owns source wording and normalization:

```yaml
requirement_id: REQ-017
role_version: ROLE-CLOUDOPS-v1
source_text: troubleshoot networking and security on AWS
work:
  - trace DNS and TCP paths
  - reason about routing and firewall policy
  - collect provider and workload evidence
environment: AWS
responsibility_hypothesis: independent bounded diagnosis
unknowns:
  - production authority
  - expected network scale
```

### Evidence record

Owns a learner-authorized claim and its limit:

```yaml
evidence_id: EVD-031
operation: diagnose a failed TCP connection
environment: local Ubuntu namespaces
class: observed
source: reviewer receipt
date: 2026-08-07
independence: reviewer supplied hidden route fault
proves: bounded path diagnosis and repair
does_not_prove: AWS VPC or production authority
permission: learner-owned
```

### Gap record

Owns the difference between required evidence and current evidence. It records criticality, dependencies and next proof. It does not say the learner is deficient as a person.

### Dependency graph

Owns prerequisite edges with rationale. Every exception needs evidence. A directed acyclic graph is useful, but learning also contains feedback loops: an incident may send you back to networking foundations.

### Capacity ledger

Owns available hours, fixed commitments, reserve, planned focus, actual throughput and stopped work. Private health or family details do not belong in a public repository; record only the capacity boundary needed for planning.

### Milestone record

Owns outcome, artifact, fault, recovery, cleanup, explanation, reviewer, acceptance and proof limit. Status values should distinguish planned, active, review required, accepted, failed, stopped and invalidated.

### Review receipt

Owns the prompt, hidden change, observed behavior, rubric anchors, critical failures and next experiment. It does not own a global level or hiring prediction.

### Roadmap decision record

Owns version changes. A useful record includes:

- previous and new role versions;
- trigger;
- evidence considered;
- retained milestones;
- reordered milestones;
- invalidated assumptions;
- stopped work;
- cost and risk;
- review date.

### State invariants

1. Every target requirement resolves to a source version.
2. Every capability claim resolves to permitted evidence and a proof limit.
3. Missing evidence never becomes observed through arithmetic.
4. A title never sets a learner level.
5. A credential never becomes production authority.
6. Planned hours plus reserve never exceed capacity.
7. Every consequential milestone has failure and recovery work.
8. Local evidence retains its environment label.
9. Independent assessment hides its answer path.
10. A roadmap change never erases the prior decision.
11. No confidential input flows to public portfolio output.
12. No score becomes a hiring prediction.

## Evidence table

The fictional packet makes six calculations visible.

### Calculation 1 — role requirement mapping

Nine versioned fictional roles contain 48 material requirements. All 48 have mappings:

```text
mapping coverage = 48 / 48 × 100 = 100.00%
```

This proves link completeness in the fixture. It does not prove that the source is still current, the normalization is correct or a learner fits the roles.

### Calculation 2 — evidence conservation

The packet contains 60 evidence rows:

```text
observed 28 + calculated 12 + qualified 8 + missing 12 = 60
attributable = 28 + 12 + 8 = 48
attributable percentage = 48 / 60 × 100 = 80.00%
```

Do not call this “80% job ready.” Twelve gaps may include a critical prerequisite, and the 48 attributable items may be guided local work.

### Calculation 3 — dependency closure

```text
resolved edges = 52
required edges = 52
edge coverage = 52 / 52 × 100 = 100.00%
cycles = 0
```

The fixture graph is structurally closed. Human review must still judge whether edges are meaningful and whether learner evidence supports an exception.

### Calculation 4 — finite annual capacity

The fictional learner has ten hours per week:

```text
annual capacity = 10 × 52 = 520 hours
fixed maintenance/review = 260 hours
new focus work = 156 hours
reserve = 104 hours
260 + 156 + 104 = 520
committed = 260 + 156 = 416
committed percentage = 416 / 520 × 100 = 80.00%
reserve percentage = 104 / 520 × 100 = 20.00%
```

The numbers are teaching fixtures. Real capacity must be learner-authorized and can change.

### Calculation 5 — milestone structure

All 24 fictional milestones contain required structural fields:

```text
structure coverage = 24 / 24 × 100 = 100.00%
reading-only milestones = 0
production claims = 0
```

Structure does not prove completion, technical correctness or competence.

### Calculation 6 — independent review classification

```text
independent reviews = 16
total reviews = 16
independence coverage = 16 / 16 × 100 = 100.00%
answer-key exposures = 0
hiring predictions = 0
```

This proves fixture labels. Real independence requires reviewer control and answer isolation.

### Evidence ladder by roadmap claim

| Claim | Minimum useful evidence | Stronger evidence | Boundary |
|---|---|---|---|
| understands inode exhaustion | teach-back plus guided lab | hidden-path remediation and delayed recall | not general Linux mastery |
| can automate a task | tested script with error handling | unfamiliar input, review and operational use | not software-engineering level |
| can deploy a service | reproducible local pipeline | stateful failure, rollback and representative release | not zero downtime |
| can operate Kubernetes | local lifecycle and faults | authorized cluster ownership across incidents/upgrades | local is not production |
| can design an SLO | defined user operation and measurement | accepted policy and longitudinal decisions | document is not outcome |
| can lead an incident | fictional simulation | authorized role, review and repeated transfer | simulation is not on-call |
| can architect a platform | reviewed design and prototype | adopted system with measured outcomes | design is not deployment |

## Command decoders

Run from the CAR-001 lab directory as a normal Ubuntu user.

### `bash lab.sh doctor`

Checks Python, fixture validity and refusal environment. Success explicitly says learner evaluation, level inference, hiring prediction and external calls are none.

### `bash lab.sh setup`

Creates one UID-scoped temporary state with an exact sentinel and two fictional files. Existing state, wrong ownership or symlinks refuse. Cleanup is mandatory.

### `bash lab.sh status`

Confirms 73 cases and packet identity. Always establish identity before trusting calculations.

### `bash lab.sh roadmap`

Lists nineteen boundary groups. Treat the list as review coverage, not proof that every real career risk is known.

### `bash lab.sh roles`

Reports 48 of 48 mapped requirements across nine versioned roles. Human review must still inspect source freshness, relevance and normalization.

### `bash lab.sh evidence`

Conserves 60 rows and keeps twelve missing. The 80% attributable value is arithmetic only.

### `bash lab.sh dependencies`

Checks 52 resolved edges and zero cycles. It cannot establish one universal learning sequence.

### `bash lab.sh capacity`

Shows 520 annual hours divided among fixed work, focus and 20% reserve. Replace fixtures only in a private authorized planning process, not by modifying expected test results.

### `bash lab.sh milestones`

Reports structural completeness and refuses reading-only or production-inflated fixture milestones. It does not mark work performed.

### `bash lab.sh reviews`

Checks independent classification, answer isolation and zero hiring predictions. It cannot judge reviewer quality.

### `bash lab.sh evaluate course-completion-equals-skill`

Returns `boundary=course-credential`. The safe next action is an evidence-shaped milestone.

### `bash verify.sh`

Runs all 73 cases, six calculations, authority refusal, unknown-artifact preservation and cleanup. Its receipt excludes learner evaluation, level inference, hiring prediction and external calls.

## Decision path

### When choosing a target role

Use a current authorized source. If several roles appeal, choose one primary and one adjacent comparison. Do not merge every requirement into one impossible persona.

### When a title differs across companies

Compare operations, responsibility and evidence—not names. Preserve both frameworks. Never “translate” a title as an exact equivalence.

### When evidence is missing

Ask whether it is foundational, specialist, representative or disclosure-limited. Choose a safe next proof. If only production authority can close it, keep it missing and develop adjacent evidence honestly.

### When a course is useful

Use it to acquire knowledge for an already-defined milestone. Acceptance remains the artifact, explanation, failure and review—not video completion.

### When considering a certification

Record current version, published domains, cost, renewal and target-role relevance. Prefer it when it fills a screening or structured-knowledge need after prerequisites. Do not let it displace higher-value practical evidence.

### When the plan exceeds capacity

Protect fixed commitments and reserve. Rank by critical prerequisite, target-role weight, evidence weakness and reuse. Stop lower-value work explicitly.

### When a milestone passes easily

Do not inflate the conclusion. Check whether the fault was hidden, recovery was verified, cleanup passed and explanation survived follow-up.

### When the target changes

Freeze the new source, create a diff and reassess dependencies. Retain transferable foundations. Invalidate only what the evidence justifies.

### When AI is used

Use sanitized inputs and bounded tasks such as categorization, question generation or critique. Verify outputs. Never let AI invent experience, infer level or secretly act during assessment.

### When to claim progress

Claim the exact receipt: “I independently diagnosed a hidden DNS failure in a local namespace and explained the request path.” Do not claim “networking mastered.”

## Guided Ubuntu lab

### Safety contract

Use Ubuntu 24.04 as a normal user. The lab is offline and fictional. Stop for root, credentials, real résumé or portfolio paths, employer systems, recordings, production endpoints or AI-service tokens.

### Establish identity

```bash
cd drafts/LES-0087-devops-sre-platform-career-roadmaps/support/lab
id
bash lab.sh doctor
bash lab.sh setup
bash lab.sh status
```

Confirm UID is not zero, packet identity is `fictional-career-roadmap-evidence` and case count is 73.

### Inspect boundaries

```bash
bash lab.sh roadmap
bash lab.sh evaluate title-proves-level
bash lab.sh evaluate course-completion-equals-skill
bash lab.sh evaluate local-lab-called-production
bash lab.sh evaluate roadmap-guarantees-job
```

Explain each refusal in your own words. The system rejects evidence promotion, not learning.

### Recalculate six views

```bash
bash lab.sh roles
bash lab.sh evidence
bash lab.sh dependencies
bash lab.sh capacity
bash lab.sh milestones
bash lab.sh reviews
```

Write every numerator, denominator and proof limit. Especially explain why 80% attributable evidence is not 80% readiness.

### Verify and clean

```bash
bash verify.sh
bash lab.sh cleanup
```

The verifier already cleans its own state. The second cleanup proves idempotent absence. Never replace exact cleanup with a broad recursive delete.

### Guided design exercise

Using only fictional data, create one requirement row for “operate reliable Kubernetes workloads.” Split it into Linux, network, workload lifecycle, state, observability, security, deployment and recovery operations. For each, name a local artifact and a proof limit. Do not score a person.

## Production transfer

### Build a private learner evidence ledger

Keep real evidence outside the public book repository. Record only what you own and may retain. Sanitize names, systems and metrics according to policy. A useful row contains operation, environment, date, authority, independence, artifact, result and proof limit.

### Construct the shared foundation

The shared trunk should connect:

1. Linux process, memory, storage, permissions and service control;
2. DNS, TCP, TLS, HTTP, routing and load balancing;
3. Git, Bash/Python and tested automation;
4. builds, artifacts, containers and CI/CD;
5. telemetry, SLOs, incidents, capacity and recovery;
6. security identity, secrets and supply-chain controls;
7. documentation and communication.

Use one evolving service so each layer interacts with previous state.

### Branch by target work

**DevOps/cloud:** deepen provider architecture, IAM, network, IaC, delivery, managed data, cost and recovery.

**SRE/production:** deepen SLO policy, telemetry, overload, on-call, incidents, toil, capacity and reliability design.

**Platform:** deepen Kubernetes, platform APIs, golden paths, tenancy, policy, developer experience and product outcomes.

**Infrastructure/private cloud:** deepen virtualization, bare metal, images, storage, software-defined networking, HA and lifecycle.

**Data platform:** deepen SQL/NoSQL, queues, streams, batch, metadata, orchestration, data quality and recovery.

**Architect/staff:** deepen requirements, cross-system state, trade-offs, governance, migration, economics, influence and organizational mechanisms.

### Responsibility progression from foundation to architect

The stages below are not titles and do not assign a learner a level. They describe increasingly broad work hypotheses that a target organization may label differently.

#### Foundation — explain and reproduce safely

The foundation learner should be able to explain a mechanism in plain language, follow a bounded procedure, compare expected with actual output, preserve the first error and clean up only owned state.

Useful evidence includes:

- tracing a process from command to kernel-visible state;
- distinguishing filesystem blocks from inodes on an exact path;
- explaining a DNS lookup and TCP connection;
- writing a small tested script with explicit failure behavior;
- building and running a container without confusing image, container and process;
- reading a pipeline or manifest and identifying inputs, state and secrets boundaries.

The responsibility boundary is narrow. Guidance is expected. Escalation is a capability, not a weakness. The unsafe shortcut is to call guided repetition “independent administration.”

#### Early-career or junior hypothesis — own a bounded task

The engineer can accept a well-scoped outcome, clarify acceptance, execute safely, test the result, document it and escalate when the observed state leaves the authority boundary.

Examples:

- repair a failed CI job whose repository and rollback path are known;
- add a tested alert annotation and verify the generated rule;
- diagnose why one container fails its health check;
- update a Terraform module through review without applying to an unauthorized environment;
- resolve a documented service issue and improve the runbook.

Evidence should show more than command execution. It should show what was expected, what differed, how evidence selected the action, what was verified and when escalation occurred.

#### Mid-level hypothesis — independently close a service outcome

The engineer handles ambiguous but bounded service work. They can trace across application, operating system, network and dependency boundaries; compare alternatives; make or obtain an authorized change; verify user recovery; and close follow-up work.

Examples:

- lead diagnosis for one service incident while preserving role boundaries;
- design and deliver a reversible deployment improvement;
- create a Terraform module interface and migration for several consumers;
- define an SLI from a user operation and improve an actionable alert;
- automate a repeated operational task with tests, observability and rollback.

The evidence needs independent fault work and technical defense. A large list of routine tickets does not automatically demonstrate this responsibility.

#### Senior hypothesis — improve systems across services and teams

The engineer owns outcomes whose dependencies cross service or team boundaries. They expose trade-offs, align decision owners, protect operational capacity, design migration and create mechanisms that reduce repeat failure.

Examples:

- change a release-safety mechanism used by several services;
- lead a complex incident with uncertain causality and coordinated recovery;
- define a platform interface and adoption path with service teams;
- redesign capacity or failure isolation using measured constraints;
- establish a security or reliability control with explicit exceptions and review.

Senior evidence is not “worked without help.” Good senior engineers seek expertise and distribute ownership. The stronger signal is accountable closure with appropriate coordination and durable improvement.

#### Lead or staff hypothesis — create cross-team leverage

The engineer identifies an important ambiguous problem, frames it as outcomes and constraints, builds a coalition, creates reusable technical and decision mechanisms, and measures whether the organization can operate them.

Examples:

- lead a multi-quarter platform or reliability strategy with reversible stages;
- establish standards and decision rights that preserve team autonomy;
- rationalize duplicated capabilities without unsafe forced migration;
- mentor technical leaders and remove an expertise bottleneck;
- connect architecture, security, cost and delivery trade-offs for a portfolio.

This work requires organizational opportunity. A learner can practise the reasoning in designs and simulations, but cannot honestly manufacture organizational adoption in a personal lab.

#### Architect hypothesis — steward a changing system of systems

The architect connects business and user operations to state, interfaces, trust, failure, capacity, economics, governance, migration and evolution. They make decisions reviewable and ensure the operating model can survive their absence.

Evidence may include:

- accepted cross-domain architecture with explicit alternatives and limits;
- migration that preserves writer authority, coexistence and recovery;
- portfolio capacity and cost decisions tied to reliability guardrails;
- governance that accelerates safe local decisions rather than centralizing every choice;
- longitudinal outcomes and revisions after real feedback.

Architecture is not the number of diagrams or products. It is the quality and durability of decisions across boundaries.

### A twelve-month shared-foundation roadmap

This example assumes a fictional capacity of ten hours per week: five hours for existing learning maintenance, review and documentation; three hours for focused new work; two hours reserve. It is a planning illustration, not a prescription.

Each month has a concept outcome, evolving-service artifact, bounded failure, explanation and review. If acceptance fails, repair the prerequisite instead of advancing by calendar.

#### Month 1 — Linux evidence and safe state change

**Concept outcome:** explain processes, filesystems, permissions, users, signals, services and exact-path resource evidence.

**Artifact:** a small service with a normal user, logs, configuration and a documented lifecycle.

**Fault:** inode exhaustion or permissions failure inside a disposable boundary.

**Recovery:** identify the exact mounted filesystem, preserve required data, remove only safe targets, restore a write and prove cleanup.

**Defense:** explain blocks versus inodes, deleted-open files, ownership and why `df` on the wrong path can mislead.

**Proof limit:** local Linux evidence, not fleet or production administration.

#### Month 2 — request-path networking

**Concept outcome:** trace name resolution, routing, ARP/neighbor discovery, TCP, TLS and HTTP.

**Artifact:** client, reverse proxy and application with request IDs and health endpoints.

**Fault:** a reviewer changes DNS, listener address, route, certificate name or proxy upstream.

**Recovery:** locate the first failing boundary, make the smallest authorized correction and verify from the client operation.

**Defense:** draw the packet/request path and distinguish timeout, refusal, TLS identity failure and HTTP response failure.

#### Month 3 — Git and tested automation

**Concept outcome:** use commits, branches, merge/rebase choices, conflict handling and rollback; write Bash and Python that fail explicitly.

**Artifact:** repository automation that validates configuration and produces structured output.

**Fault:** empty input, missing key, bad path, permission error or conflicting change.

**Recovery:** preserve diagnostics, add a regression test and explain the public interface.

**Boundary:** generated success cannot hide an exception or destructive default.

#### Month 4 — builds, packages and artifacts

**Concept outcome:** understand dependency resolution, build inputs, immutable artifacts, provenance and promotion.

**Artifact:** versioned application package or image built by a repeatable command with tests and checksum.

**Fault:** dependency drift, missing artifact, architecture mismatch or corrupted cache.

**Recovery:** invalidate only the relevant cache, reproduce the build and verify artifact identity.

**Defense:** explain why rebuilding separately in every environment weakens promotion evidence.

#### Month 5 — containers and delivery

**Concept outcome:** connect image layers, namespaces, cgroups, process lifecycle, networking, storage and signals to delivery.

**Artifact:** containerized evolving service plus CI stages for test, build, scan and local deployment.

**Fault:** non-root write failure, health-check mismatch, signal-handling problem or incompatible configuration.

**Recovery:** correct the contract, rebuild immutably and prove rollback.

**Security:** no secret in image layers or logs.

#### Month 6 — observability and SLO foundations

**Concept outcome:** derive metrics, logs and traces from a user operation; distinguish signals from objectives.

**Artifact:** telemetry for request success, latency and saturation, with one dashboard and actionable alert.

**Fault:** service appears process-healthy while the user operation fails.

**Recovery:** use telemetry to locate the boundary; repair the service and verify the user journey.

**Defense:** explain cardinality, missing telemetry, alert ownership and why a dashboard is not an SLO.

#### Month 7 — infrastructure as code and configuration

**Concept outcome:** reason about desired state, state ownership, plan, drift, module interfaces and mutable configuration.

**Artifact:** local or non-provider Terraform-style model and Ansible-style configuration with validation and idempotence receipts.

**Fault:** drift, state lock, partial configuration or unsafe replacement proposal.

**Recovery:** inspect before mutation, preserve authority, plan the repair and validate without unauthorized apply.

**Boundary:** no cloud credential is required for conceptual evidence.

#### Month 8 — Kubernetes mechanisms

**Concept outcome:** explain API desired state, controllers, scheduling, pods, services, networking, storage, identity and admission.

**Artifact:** local workload with readiness, resources, policy, persistent state and rollout.

**Fault:** Running pods but failed requests; pending scheduling; DNS; policy; PVC; or rollout regression.

**Recovery:** trace user operation through cluster state, choose a reversible action and verify.

**Proof limit:** local cluster operations, not managed or on-premises fleet ownership.

#### Month 9 — reliability and incident operation

**Concept outcome:** use SLI/SLO/error-budget reasoning, incident roles, hypothesis discipline, recovery evidence and post-incident learning.

**Artifact:** incident packet, runbook, error-budget policy and one toil-reduction change for the evolving service.

**Fault:** reviewer combines overload with a misleading correlated dependency signal.

**Recovery:** separate impact, observations, hypotheses, action and later cause. Communicate verified state.

**Human boundary:** sustainable practice and role relief are part of reliability.

#### Month 10 — security and supply chain

**Concept outcome:** map trust boundaries, least privilege, secrets, certificates, dependencies, SBOM/signing concepts and policy.

**Artifact:** threat model and local delivery controls tied to the service.

**Fault:** exposed secret fixture, unsigned artifact, vulnerable dependency or overly broad identity.

**Recovery:** contain fictional state, rotate only synthetic credentials, repair the pipeline and preserve audit evidence.

**Boundary:** never place real secrets in the exercise.

#### Month 11 — performance, capacity and resilience

**Concept outcome:** define workload units, queues, saturation, latency distributions, timeouts, retries, backpressure and failure isolation.

**Artifact:** load model and bounded test with capacity estimate, overload behavior and cost assumptions.

**Fault:** retry amplification, slow dependency, uneven load or exhausted worker pool.

**Recovery:** protect the user operation with bounded concurrency, timeout budgets, graceful degradation or isolation as justified.

**Defense:** distinguish benchmark fixture from production capacity.

#### Month 12 — integration, architecture and independent defense

**Concept outcome:** integrate user outcome, requirements, state, interfaces, trust, failure, delivery, operations, capacity, cost and evolution.

**Artifact:** complete evolving-service portfolio with ADRs, diagrams, runbooks, incident history, tests and evidence index.

**Fault:** reviewer changes scale, region, consistency, team or budget.

**Recovery/design revision:** update the architecture and roadmap through a versioned decision, not by pretending the original solved every constraint.

**Acceptance:** independent project defense, incident simulation and delayed unfamiliar transfer. No automatic title or mastery award follows.

### How to compress or extend the twelve months

Calendar time is not the invariant. Evidence and dependencies are. A learner with more relevant experience may demonstrate a prerequisite early and document the reviewer evidence for an exception. A learner with four hours per week may take longer. Never compress by deleting recovery, review or sleep.

If a month fails, keep the evolving service stable and repair the gap. If the target role changes, retain shared work and create a branch. If motivation drops, reduce work in progress and choose a smaller end-to-end outcome rather than adding novelty.

### Specialist branch A — DevOps and cloud engineering

This branch asks: can the learner move a tested change through infrastructure and delivery controls while preserving identity, state, rollback, observability, security and cost?

After the shared Linux/network/software foundation:

1. **Provider concept map:** translate compute, network, identity, storage, database, messaging, monitoring and serverless services across AWS, Azure and Google Cloud without pretending they are identical.
2. **Primary provider depth:** choose the provider required by the target role. Learn resource hierarchy, identity, networking, quotas, control-plane behavior, logging and cost model.
3. **IaC state and modules:** create module contracts, plan review, environment separation, policy, drift and recovery. Provider execution remains optional and authorized.
4. **Delivery:** design artifact promotion, workload identity, progressive rollout, rollback and audit.
5. **Reliability:** add availability zones/regions, backup/restore, dependency failure, capacity and cost guardrails.
6. **Independent defense:** reviewer changes region, identity, budget or data residency. Adapt the design and state what requires real provider verification.

Local-first artifact: an emulator or declarative model plus diagrams, policy tests and failure reasoning. Stronger later evidence: authorized provider sandbox receipts. Production evidence remains separate.

### Specialist branch B — site reliability and production engineering

This branch asks: can the learner connect user outcomes to software and operational mechanisms, then improve reliability without sacrificing sustainable engineering?

Deepen:

- SLI semantics, measurement windows and data quality;
- SLO and error-budget policy;
- symptom-based alerting and ownership;
- incident command, communication and relief;
- overload, queuing, retries, timeout budgets and graceful degradation;
- capacity forecasting and load-test limits;
- toil measurement and software automation;
- post-incident action quality and longitudinal verification;
- on-call sustainability and service engagement models.

Portfolio milestone: operate the evolving local service through several reviewer-controlled incidents. Preserve timelines, hypotheses, recovery, communications and prevention diffs. Do not call the exercise a real on-call rotation.

Senior defense: a reviewer asks whether higher availability is worth its engineering and opportunity cost. Respond using user need, failure budget, architecture, staffing, operational load and alternatives—not “five nines is best.”

### Specialist branch C — platform engineering

This branch asks: can the learner create reusable capabilities that make safe developer outcomes easier without turning the platform team into a ticket queue?

Deepen:

1. user research and painful developer operations;
2. platform product outcomes and adoption;
3. APIs, templates and golden-path contracts;
4. Kubernetes or other runtime abstraction;
5. tenancy, identity, policy and secret boundaries;
6. service catalog and ownership metadata;
7. portal concepts such as Backstage without equating portal with platform;
8. telemetry for user journeys and platform reliability;
9. extension, exception and escape-hatch design;
10. operating model, support and deprecation.

Artifact: a small self-service service-bootstrap and deployment path that produces owned, tested, observable output. Fault: template version changes, policy rejects a workload or the control plane is unavailable. Recovery must protect workloads and explain reconciliation.

Organizational maturity models describe platform practices and outcomes. They do not score an individual engineer.

### Specialist branch D — infrastructure and private cloud

This branch asks: can the learner reason from hardware and virtualization through storage, networking and cloud control planes?

Sequence:

- CPU, memory, NUMA, disks, NICs and firmware concepts;
- KVM/QEMU and libvirt lifecycle;
- images, cloud-init and immutable/mutable configuration;
- bridges, VLAN/VXLAN, routing and software-defined networking;
- block, file and object storage; replication and failure domains;
- OpenStack-style identity, compute, network, image and volume control planes;
- Ceph-style placement, quorum, recovery and capacity;
- bare-metal provisioning and lifecycle;
- monitoring, upgrades, evacuation, backup and disaster recovery;
- fleet capacity, power, cost and decommission.

Local evidence can model VM and network lifecycles when hardware allows. A small Ceph or OpenStack simulation cannot prove data-center operation. Preserve that boundary.

Independent fault examples: failed hypervisor evacuation, network control-plane disagreement, degraded storage quorum, image incompatibility or capacity imbalance. The reviewer controls the failure and checks state before action.

### Specialist branch E — data and ML platform operations

This branch asks: can the learner preserve data correctness, freshness, lineage, reproducibility and serving reliability across pipelines?

Start with SQL transactions, indexes and recovery; then compare NoSQL and cache state. Add queues, delivery semantics, idempotency, schemas and replay. Continue into batch/stream processing, orchestration, lake/table formats, catalogs, quality, feature/ML lineage and serving.

Artifact: a local event-to-batch-to-serving path with:

- source and event-time identity;
- schema contract;
- checkpoint or offset state;
- duplicate handling;
- data-quality assertions;
- backfill;
- lineage;
- freshness SLI;
- privacy-safe telemetry;
- recovery runbook.

Faults include silent schema evolution, poison records, checkpoint loss, duplicate side effects, late data, stale serving or partial backfill. A green scheduler is not proof of fresh correct data.

### Specialist branch F — lead, staff and architect

This is not a shortcut around implementation. It builds on deep mechanisms and adds wider decision responsibility:

- translate strategy into measurable outcomes and constraints;
- create current and target architecture views with state and trust;
- compare alternatives, including doing less;
- estimate capacity and cost with uncertainty;
- design migration, coexistence, rollback and decommission;
- establish decision rights, standards and exceptions;
- communicate across engineering, security, finance and product;
- preserve dissent and psychological safety;
- delegate with authority and checkbacks;
- measure adoption, operational outcomes and unintended effects.

Practice artifact: a strategy and migration dossier for the evolving service platform. Independent review changes budget, deadline, regulatory boundary and one critical dependency. The learner must replan rather than defend the original.

### Role-to-evidence milestone matrix

| Target path | First defensible artifact | Essential failure | Senior follow-up | Evidence that must remain missing when unavailable |
|---|---|---|---|---|
| DevOps | tested artifact promotion pipeline | incompatible release and rollback | how are approvals and secrets bounded? | organizational deployment ownership |
| Cloud | provider-neutral design plus primary-provider model | region, IAM or quota failure | what is verified versus assumed? | real provider behavior without sandbox |
| SRE | SLO, alert and incident packet | overload plus misleading signal | which reliability trade-off is justified? | production on-call |
| Platform | self-service golden path | control-plane or policy failure | how is adoption and escape handled? | organization-wide developer outcome |
| Private cloud | VM/network/storage lifecycle model | host, network or quorum degradation | how do evacuation and recovery interact? | data-center fleet operation |
| Data platform | observable pipeline and replay | duplicate, schema or freshness failure | how is correctness protected during backfill? | regulated production data operation |
| Security | threat model and enforced local control | secret, identity or supply-chain failure | how do exceptions expire and audit? | organizational risk acceptance |
| Architect | reviewed system/migration dossier | changed constraint and failed dependency | what decision is reversible? | adopted cross-organization strategy |

### Certification decision record

Before scheduling any credential, write:

```yaml
credential:
  exact_name: current official name
  version: current exam version
  target_requirement: requirement ID
  purpose: structured knowledge or screening signal
  prerequisites:
    - evidence IDs
  cost:
    money: learner-authorized estimate
    preparation_hours: bounded estimate
  alternatives:
    - practical milestone
    - no credential
  proof_limit: does not prove production ownership or hiring
  review_date: YYYY-MM-DD
```

If the credential does not serve a current role requirement or learning gap, defer it. If it does, integrate its domains into practical work instead of creating a separate memorization universe.

### Portfolio construction from completed evidence

Build the portfolio after milestones close. Each entry answers:

1. What user or operator outcome mattered?
2. What exact environment and authority existed?
3. What was designed or changed?
4. Which failure was tested?
5. How was recovery verified?
6. Which security, reliability, performance and cost limits remain?
7. Which files let another person reproduce or review it?
8. What was learned and changed later?

Avoid screenshots without context, giant repositories without navigation and claims such as “production-grade” without a declared acceptance contract. A concise evidence index is more useful than decorative scale.

### Interview preparation from the roadmap

Every accepted milestone can feed a truthful story:

- Linux incident becomes evidence-first diagnosis;
- networking fault becomes request-path reasoning;
- pipeline rollback becomes release safety;
- SLO exercise becomes reliability trade-off;
- platform milestone becomes user and interface design;
- migration dossier becomes architecture defense;
- failed milestone becomes accountability and learning.

Use CAR-001 to choose evidence and LES-0086 to shape answers. Do not write interview achievements before performing the work.

### The first ninety days for a foundation learner

This is a learning plan, not a promise to become employable in ninety days.

#### Days 1–30 — make one Linux service understandable

Build the smallest service that has a process, configuration, log, port and file output. Learn to answer:

- Which user runs it?
- Which executable and arguments exist?
- Which files are read and written?
- Which filesystem holds those paths?
- Which port and address are bound?
- How does it start and stop?
- Which signals and exit codes matter?
- What proves the user operation works?

Introduce only bounded Linux faults: permissions, missing configuration, wrong listener and inode pressure in disposable state. Keep an evidence notebook with command, output, interpretation, alternative and next check.

Acceptance is a reviewer-supplied exact-path failure, successful recovery and teach-back. “Finished Linux basics” is not acceptance.

#### Days 31–60 — trace the request and automate evidence

Put a client and proxy in front of the service. Trace DNS, TCP, TLS when enabled and HTTP. Add request IDs. Write a small Python or Bash diagnostic that accepts explicit inputs, validates them and returns a nonzero exit on failure.

The reviewer changes one boundary. The learner predicts expected evidence before running commands. This prevents random-command troubleshooting.

Acceptance includes a tested script, request-path diagram, hidden failure receipt and cleanup. The script must not require root or broad network authority.

#### Days 61–90 — deliver, observe and recover

Package the service into a container, build it reproducibly and create a local CI workflow. Add health semantics, metrics/logs and a rollback path. Inject a failed release.

Acceptance includes immutable artifact identity, test results, failure signal, rollback verification, user-operation recovery and one lesson that changes the pipeline. This creates the first end-to-end portfolio unit.

### Thirty-sixty-ninety onboarding is a different artifact

A job onboarding plan begins after joining an authorized organization. Do not present the learning plan above as if it were a real onboarding commitment.

A safe hypothetical onboarding model is:

**First 30 days:** understand users, services, ownership, access, policies, change process, telemetry, on-call expectations and current risks. Make no broad redesign promise.

**Days 31–60:** take bounded ownership, shadow or join authorized operations, close small improvements and validate the system map with maintainers.

**Days 61–90:** independently close appropriate outcomes, propose one evidence-backed improvement and agree on longer-term gaps with the manager and team.

The actual employer controls priorities, access and level expectations.

### Debugging a roadmap that is not working

Treat a stalled roadmap like a production problem.

#### Signal: many starts, few accepted milestones

Likely mechanisms include too much work in progress, unclear acceptance, missing prerequisites or novelty seeking.

Evidence:

- active milestone count;
- time since last accepted receipt;
- dependency rework;
- context-switch count;
- stopped-work decisions.

Repair: reduce active work to one or two milestones, define acceptance and finish the smallest end-to-end slice.

#### Signal: commands are remembered but incidents remain confusing

Likely mechanism: tool recall without system model.

Evidence:

- inability to predict command output;
- no request/state diagram;
- commands selected before hypotheses;
- confusion between symptom and cause.

Repair: require “question, expected branches, meaning, next evidence” for every command. Draw state ownership and fault paths.

#### Signal: lab scores rise but new tasks fail

Likely mechanism: answer-key or fixture dependence.

Evidence:

- same question order;
- immediate repeats;
- reviewer changes cause collapse;
- facts memorized without mechanism.

Repair: hide the fault, delay reassessment, change topology and ask for explanation before commands.

#### Signal: the plan is consistently missed

Likely mechanisms include optimistic estimates, unrecorded fixed commitments, insufficient reserve or a changed life constraint.

Evidence:

- planned versus actual focus hours;
- reserve consumption;
- unplanned obligations;
- milestone-size variance.

Repair: rebaseline from observed throughput. Do not use shame or permanent overtime as a control.

#### Signal: portfolio grows but role gaps remain

Likely mechanism: projects optimize visibility rather than target work.

Evidence:

- artifact-to-requirement links;
- repeated technologies;
- missing critical operations;
- no representative or independent review.

Repair: choose the highest-risk target gap and extend an existing project with that mechanism.

#### Signal: every review says “good”

Likely mechanisms include weak rubrics, non-independent reviewers or politeness bias.

Evidence:

- absence of quoted observations;
- no hidden changes;
- no failed gates;
- feedback cannot specify a next experiment.

Repair: use observable anchors, changing constraints and explicit permission to identify failure. Rotate reviewers where possible.

### How to choose the next milestone

Score decisions, not people. A simple priority discussion may consider:

```text
priority evidence =
  target-role importance
  × gap criticality
  × prerequisite leverage
  × transfer reuse
  ÷ estimated focus cost
```

Do not turn this into false mathematical precision. Use small ordinal values, inspect sensitivity and apply hard safety or prerequisite constraints before ranking. If two items are close, choose the smaller reversible experiment.

Example:

| Candidate | Role weight | Gap | Leverage | Reuse | Cost | Decision |
|---|---:|---:|---:|---:|---:|---|
| DNS/TCP diagnosis | high | high | high | high | medium | first |
| second cloud CLI | medium | high | low | medium | medium | defer |
| local SLO exercise | high | high | medium | high | medium | next |
| another dashboard theme | low | low | low | low | low | stop |

The table explains a decision. It does not compute learner worth.

### Evidence expiry and maintenance

Roadmap evidence ages for several reasons:

- product version or API changed;
- certificate expired;
- role source changed;
- the artifact no longer builds;
- the learner cannot explain it after delay;
- permission to retain it changed;
- stronger evidence contradicts the old claim.

Set review triggers. Re-run only what matters. Preserve historical evidence but mark it stale. A maintenance cycle can be smaller than initial learning: rebuild, rerun one fault, explain changes and update proof limits.

### Working with mentors and reviewers

A mentor may help select work, explain mechanisms and open legitimate opportunities. A reviewer must still report observable evidence rather than personal endorsement.

Give reviewers:

- target role version;
- milestone acceptance;
- safety boundary;
- authority to change one constraint;
- rubric;
- retention and confidentiality rules.

Do not ask a mentor to “certify senior.” Ask: “Which responsibility is unobserved, which evidence would be meaningful, and what safe opportunity could expose it?”

### A sustainable weekly operating template

Use this only after replacing the hours with an actual capacity decision.

**Session 1 — retrieve and model:** without notes, redraw the relevant request/state path and answer several memory prompts. Open the source afterward and repair misconceptions. The output is a gap note, not a completion mark.

**Session 2 — implement the smallest change:** work on one artifact. Define the intended invariant and validation before editing. Commit a reviewable slice.

**Session 3 — inject or investigate failure:** use a bounded fault. Predict the first failing evidence, observe, update the hypothesis and recover. Never introduce destructive or external faults merely to satisfy a schedule.

**Session 4 — explain and review:** teach the mechanism, show evidence, state the proof limit and receive one changing follow-up. Convert feedback into a specific experiment.

**Reserve:** leave time unallocated. If no surprise occurs, use reserve for rest, documentation, cleanup or light retrieval—not for silently starting another large milestone.

A fictional ten-hour week might allocate:

```text
foundation retrieval and maintenance = 2.0 hours
focused implementation              = 3.0 hours
failure and recovery                = 2.0 hours
review and documentation            = 1.0 hour
reserve                             = 2.0 hours
total                               = 10.0 hours
```

If implementation consumes five hours, do not steal from sleep or pretend failure testing happened. Use two reserve hours, record the variance, and keep later acceptance work open.

### Monthly and quarterly review questions

At month end:

- Which receipt closed and what exactly does it prove?
- Which expected output differed?
- Where did a prerequisite fail?
- How much focus and reserve were actually consumed?
- Which work stayed active too long?
- Which evidence became stale or prohibited?
- What should stop next month?

At quarter end:

- Is the role source still current?
- Did target operations or personal constraints change?
- Can an independent reviewer reproduce the claimed evidence?
- Does the learner transfer the model after a delay?
- Are portfolio and interview claims still bounded?
- Which critical gap has no safe local proof?
- Does the next quarter deepen one branch or scatter across several?

The output is a versioned diff. “Work harder” is not a valid remediation without a specific mechanism and sustainable capacity change.

### Example milestone specification

```yaml
milestone_id: MS-NET-003
role_requirements: [REQ-004, REQ-011]
outcome: trace and recover a failed HTTPS request path
prerequisites:
  - DNS resolution model
  - TCP connection states
  - TLS identity and trust
artifact:
  - local client, proxy and service
  - request-path diagram
  - evidence capture script
hidden_change_owner: independent reviewer
allowed_faults:
  - wrong DNS answer
  - closed listener
  - certificate name mismatch
  - invalid proxy upstream
acceptance:
  - predicts evidence at each boundary
  - identifies first failure
  - performs smallest owned repair
  - verifies user operation
  - proves cleanup
proof_limit: local namespaces; no production or cloud-network authority
status: review-required
```

This record makes “learn networking” executable without pretending the selected four faults cover the whole domain.

### Evidence index for an evolving service

Keep a short index so a reviewer does not search a large repository:

| Evidence ID | Operation | Artifact | Environment | Independent change | Proof limit |
|---|---|---|---|---|---|
| EVD-LNX-01 | exact-path storage diagnosis | incident receipt | local container | inode exhaustion | no host-fleet work |
| EVD-NET-01 | HTTPS request trace | diagram and capture | namespaces | TLS name mismatch | no cloud LB |
| EVD-CICD-01 | release rollback | pipeline receipt | local runner | incompatible config | no production release |
| EVD-SRE-01 | SLO incident response | timeline/runbook | simulation | overload and stale signal | no real on-call |
| EVD-ARC-01 | changed-constraint design | ADR and model | review exercise | region removed | no adopted architecture |

Every public claim should resolve to one or more safe entries. Private evidence may use a separate access-controlled index.

### When production opportunity is unavailable

You can still progress:

- build faithful local mechanisms;
- contribute to public open-source work under project rules;
- review public incident reports and reproduce safe failure classes;
- design and defend architectures;
- volunteer only where authorization, safety and support are real;
- seek roles with supervised operational exposure.

Never create unauthorized production risk to obtain experience. Preserve the gap and build the strongest adjacent evidence possible.

### Quarterly operating rhythm

At the start: freeze role version, capacity and evidence gaps. Monthly: close at most a few evidence-shaped milestones. Quarterly: run independent unfamiliar work, audit proof limits, update the role source and create a roadmap diff.

### Portfolio boundary

A portfolio entry states environment and authority first. “Local Docker Compose service” is credible. “Enterprise platform” without enterprise evidence is not. Include failures and limits; they demonstrate judgment.

## Reliability, security, observability, capacity, and cost

### Reliability of learning

Reduce single points of failure: do not depend on one tutorial, one project, one reviewer or one memorized explanation. Use spaced retrieval, multiple contexts, fault injection and delayed transfer.

### Security and privacy

Minimize data. Keep credentials, private repositories, customer facts, employee records and recordings out. Use fictional fixtures for public labs. Respect employer and certification rules.

### Observability

Track actionable signals: milestone lead time, failed acceptance reason, unsupported claims, dependency rework, actual focus hours, reserve consumption and delayed-transfer observations. Do not create vanity dashboards from lesson counts.

### Capacity

Use real sustainable constraints. Work in progress is a queue: adding simultaneous topics increases wait and context switching. Protect reserve and stop work deliberately.

### Cost

Count money, time, hardware, subscriptions, exam fees and opportunity cost. Prefer local simulations until a provider environment is necessary and authorized. A free tool can still have high operational and cognitive cost.

### Accessibility and sustainability

Choose formats the learner can use. Provide text alternatives, keyboard access, readable contrast and adjustable pacing. On-call endurance, sleep loss and permanent overtime are not career milestones.

## Traps and prevention

| Trap | Prevention |
|---|---|
| “learn everything” | one primary role, shared trunk, one branch |
| title-based roadmap | compare observable responsibility |
| course equals competence | artifact, fault, recovery, review |
| certification equals production | preserve exam scope and environment gap |
| local equals enterprise | label topology, authority and limit |
| years equal seniority | examine autonomy, scope, complexity and influence |
| every gap is equal | critical prerequisites and risk first |
| no reserve | protect capacity before accepting focus work |
| happy-path project | inject bounded failure and prove cleanup |
| generic role map | preserve operating context |
| portfolio-only work | connect evidence to actual target operations |
| self-review only | reviewer-controlled hidden change |
| instant repetition | delayed unfamiliar transfer |
| rewrite old plan | versioned diff and decision record |
| AI-generated experience | learner-owned evidence only |
| hiring percentage | report coverage and gaps, not prediction |
| confidential proof | sanitize or choose another artifact |
| endless study | milestone acceptance and stopped work |
| tool collecting | mechanisms and user outcomes |
| company dependence goal | build shared systems and reduce key-person risk |

## Memory card and retrieval

Answer before reading the complete answers:

1. Why is a title not a portable level?
2. What separates a requirement from a competency?
3. Which dimensions describe responsibility?
4. What is a proof limit?
5. Why preserve missing evidence?
6. How does guided work differ from independent transfer?
7. Why can certification not prove production ownership?
8. What is the shared foundation trunk?
9. Why do specialist branches diverge?
10. What makes a prerequisite edge useful?
11. Why protect capacity reserve?
12. What closes a milestone?
13. Why is a local lab still valuable?
14. What does 80% attributable evidence mean?
15. How should a changed role affect the plan?
16. What belongs in a review receipt?
17. When may AI assist roadmap work?
18. Why is a generic roadmap unsafe?
19. What evidence supports broader responsibility?
20. What must remain outside this repository?

### One-minute card

```text
ROLE VERSION -> WORK -> RESPONSIBILITY -> EVIDENCE -> GAP
GAP -> DEPENDENCY -> CAPACITY -> MILESTONE -> REVIEW -> TRANSFER

Milestone = explanation + artifact + fault + recovery + cleanup + review
Claim = environment + authority + receipt + proof limit
Progress = exact evidence, never title or hiring prediction
Preserve reserve, stopped work, confidentiality and old decisions.
```

## Complete answers

### Answer 1 — title portability

A title is assigned inside an organization’s structure. “Senior” may mean independent ownership of one service in one company and cross-team technical leadership in another. Compare the work, autonomy, scope, complexity, influence, authority and impact. Preserve titles as source facts, not universal levels.

### Answer 2 — requirement and competency

A requirement is versioned source wording for a job. A competency is integrated knowledge and skill used in context to produce an outcome. “Terraform required” is a requirement; safely modelling desired state, reviewing a plan, managing state ownership and recovering from drift are parts of competency.

### Answer 3 — responsibility dimensions

Use autonomy, scope, complexity, influence, impact, authority and accountability. Tool depth contributes but does not replace these dimensions. Broader responsibility should be supported by decisions and outcomes, not personality language.

### Answer 4 — proof limit

A proof limit names what evidence cannot establish. A passing local rollback test may prove the scripted recovery in that topology; it cannot establish multi-region production reliability. Proof limits prevent useful small evidence from becoming a false large claim.

### Answer 5 — missing evidence

Missing state keeps the roadmap honest and actionable. It identifies the next safe proof or reveals that only authorized representative work can close the gap. Removing the label without evidence is not progress; it is data corruption.

### Answer 6 — guided and independent

Guided work supplies a known path and is excellent for learning mechanisms. Independent transfer withholds the answer path, lets a reviewer change constraints and observes whether the learner can select and adapt the model. Both matter; they prove different things.

### Answer 7 — certification boundary

A certification evaluates a versioned published domain under defined rules. It does not observe production authority, organizational coordination, longitudinal outcomes or every failure mode. Record it precisely and combine it with practical evidence.

### Answer 8 — shared trunk

The shared trunk is Linux and systems, networking, software and automation, build and delivery, observability and reliability, security, and documentation/communication. These mechanisms recur across DevOps, SRE, cloud, platform, private-cloud and data work.

### Answer 9 — branch divergence

Roles own different state and consequences. Cloud operations emphasizes provider APIs, IAM and managed services. Private cloud adds hardware, virtualization, storage and software-defined networking. Data platforms add schemas, pipelines, quality and replay. A common trunk cannot erase these differences.

### Answer 10 — prerequisite edges

A useful edge explains causal learning value. Linux process and cgroup knowledge supports container diagnosis; request-path networking supports Kubernetes service debugging. The rationale lets a reviewer challenge or approve an exception.

### Answer 11 — reserve

Reserve absorbs review, unexpected difficulty, illness and recovery. Without it, the first surprise forces hidden overtime or skipped validation. Reserve makes a plan reliable rather than lazy.

### Answer 12 — milestone closure

A consequential milestone closes with concept explanation, a working artifact, bounded fault, safe recovery, cleanup proof, independent review and delayed transfer where appropriate. Its acceptance and proof limit are defined before execution.

### Answer 13 — local value

Local labs permit repetition, safe fault injection and inspection of internals at low cost. They can provide strong bounded evidence. Their limitation is environment, authority, scale and organizational consequence—not educational worth.

### Answer 14 — eighty percent

In the fixture, 48 of 60 evidence rows are observed, calculated or qualified, so attribution is 80%. It is not readiness because rows differ in criticality and strength; twelve missing rows may include essential work. The number validates conservation only.

### Answer 15 — changed target

Freeze the new source and create a roadmap version diff. Retain transferable foundations, add new requirements, invalidate stale assumptions, reorder dependencies, stop lower-value work and record the decision. Never rewrite the prior plan.

### Answer 16 — review receipt

Record prompt, environment, hidden constraint, requested outcome, observed actions, artifact identity, failure/recovery evidence, rubric anchors, critical boundary failures, proof limits and next experiment. Exclude global personality, level and hiring predictions.

### Answer 17 — AI boundary

AI may organize sanitized requirements, propose fictional faults, question assumptions or compare a learner-authored plan with a rubric. A human verifies output. AI must not consume prohibited data, invent experience, assign level or secretly assist a restricted assessment.

### Answer 18 — generic roadmap risk

Generic paths ignore role context, current evidence, constraints and dependencies. They either omit critical specialist work or include everything. Use a shared foundation plus a branch derived from a current target role.

### Answer 19 — broader responsibility

Evidence may include independently resolving ambiguous work, coordinating several services, creating mechanisms adopted by multiple teams, making reviewed trade-offs, delegating safely and producing longitudinal outcomes. One large project or confident presentation is insufficient by itself.

### Answer 20 — public repository boundary

Keep secrets, credentials, private source, customer or employee data, internal endpoints, unauthorized recordings, sensitive career evidence and employer-confidential artifacts outside. Store only fictional or explicitly safe teaching material and public source references here.

## Product-company interview

These fictional scenarios are derived from public role themes and the supplied nine-company heat map. They do not reproduce confidential questions or guarantee current interview processes.

### Scenario 1 — Apple-style data operations path

**Prompt:** “Build a twelve-month path toward operating batch and real-time data/ML infrastructure.”

Start with Linux, networking, Python, data contracts, SQL and one observable pipeline. Add orchestration, batch/stream state, idempotency, backfill, quality, lineage and recovery before collecting every named product. Then branch into Spark/Flink/Airflow/Iceberg or equivalent concepts, Kubernetes delivery, observability, security and cost.

**Follow-up:** “You have no production data platform.” Keep that gap explicit. Build local failure and recovery evidence; do not claim scale.

### Scenario 2 — Experian-style AWS SRE path

Map EC2/EKS/ECS/RDS/S3/Lambda/CloudWatch/IAM/VPC wording into compute, scheduling, state, object storage, event execution, telemetry, identity and networking operations. Shared prerequisites come first. Model locally until provider authority exists.

**Challenge:** “Should certification be first?” Use the current exam guide after foundation if it structures gaps or supports screening; never let it replace incidents and recovery.

### Scenario 3 — Mastercard-style senior SRE

The role emphasizes AWS/EKS production ownership, automation, observability, incidents and collaboration. The roadmap must seek evidence of end-to-end service responsibility and changed-constraint operations, not only cluster commands.

**Challenge:** “The learner has eight years.” Years remain context. Ask what autonomous and cross-team outcomes are evidenced.

### Scenario 4 — Cisco-style private cloud

Branch into Linux internals, networking, virtualization, control planes, storage, capacity, HA and lifecycle. Use KVM/libvirt and bounded OpenStack/Ceph/OVS/OVN models where local capability allows.

**Challenge:** “Can AWS labs substitute?” They support shared mechanisms but not private-cloud hardware, storage and network-control responsibilities.

### Scenario 5 — Visa-style payment reliability

Prioritize security, data integrity, latency, availability, audit, incident evidence and controlled delivery. Use fictional payment operations; never copy regulated or customer data.

**Challenge:** “Add a dramatic payment metric.” Only if permitted evidence has baseline, denominator, unit, window and attribution.

### Scenario 6 — GitLab-style remote platform work

Include asynchronous documentation, software development, CI systems, distributed collaboration, observability and transparent decision records alongside infrastructure.

**Challenge:** “Does public handbook similarity prove fit?” No. It informs one context; learner evidence and authorized assessment remain separate.

### Scenario 7 — NVIDIA-style compute infrastructure

Add on-premises Kubernetes, containerd, scheduling, GPU/CPU/DPU concepts, CI compute, data-center operations, Python/Go, databases and analytics. Hardware and fleet evidence remain gaps when only simulations exist.

**Challenge:** “Should GPU topics precede systems?” Preview them, but scheduling and performance reasoning depend on operating-system, networking and workload foundations.

### Scenario 8 — Arm-style infrastructure/platform

Preserve architecture-specific and embedded or hardware-adjacent context when present in the actual role. Do not assume a generic SaaS roadmap covers it.

**Challenge:** “The public description is incomplete.” Record unknowns and prepare clarification questions rather than inventing team topology.

### Scenario 9 — ADP-style AWS engineering

The supplied role combines Linux/Windows, Python/JavaScript/Shell, Terraform/CloudFormation/Ansible, databases and advanced networking. Sequence durable mechanisms, then create an explicit Windows/PowerShell branch instead of treating Linux commands as portable.

**Challenge:** “Learn every database deeply.” Select operations required by the target role and learn comparative state/recovery first.

### Scenario 10 — junior DevOps roadmap

Bounded execution, explanation and safe escalation matter more than architecture theater. Build one service, automate tests, package it, deploy locally, instrument it, break it and recover it.

**Follow-up:** “How can leadership appear?” Through ownership of a bounded outcome, clear communication, risk surfacing and useful documentation—not invented authority.

### Scenario 11 — mid-level SRE roadmap

Seek independent service diagnosis, SLO reasoning, safe changes, incidents, capacity and toil automation. Add unfamiliar faults and communication receipts.

**Follow-up:** “What distinguishes this from junior?” Less routine guidance, broader state reasoning and independently closed outcomes, calibrated to the organization.

### Scenario 12 — senior platform roadmap

Move from operating tools to platform-user outcomes, APIs, tenancy, policy, adoption, reliability and operating mechanisms across teams.

**Follow-up:** “Does building Backstage prove platform engineering?” A portal is one interface. User research, capabilities, ownership and outcomes remain necessary.

### Scenario 13 — staff engineer roadmap

Focus on ambiguous cross-team problems, reusable decision mechanisms, migration, influence and measurable organizational outcomes while preserving technical depth.

**Follow-up:** “Can a personal project prove staff level?” It can show reasoning and technical work, not organizational influence or employer-specific level.

### Scenario 14 — architect roadmap

Integrate requirements, state, interfaces, security, failure, capacity, cost, governance, migration and evolution. Require design defense plus implementation feedback.

**Follow-up:** “How many certifications?” None is universally required. Decide from target-role evidence, cost and current credential contract.

### Scenario 15 — career change from systems administration

Preserve Linux, troubleshooting and operational evidence. Add software engineering, versioned IaC, testing, delivery and modern observability. Do not discard real transferable work because titles differ.

**Follow-up:** “Can years in administration become cloud years?” No. Map transferable mechanisms and keep provider experience explicit.

### Scenario 16 — capacity shock

The learner’s weekly capacity falls from ten hours to four. Protect two hours of foundation maintenance/review, reserve one hour and allow one hour of focus, or choose another explicit allocation. Stop milestones; do not compress twelve months into nights.

**Follow-up:** “Won’t this be too slow?” It is slower on paper and more executable in reality. Re-evaluate target timing without sacrificing safety or health.

### Worked example 1 — a role change without losing progress

Assume a fictional learner originally targets a public-cloud SRE role. The version-one plan allocates 520 annual hours:

```text
fixed foundation maintenance and review = 260
AWS/SRE focus work                    = 156
reserve                               = 104
total                                 = 520
```

After one quarter, the target changes to an on-premises platform role emphasizing Kubernetes, KVM, Ceph, networking and CI compute. A weak response deletes the AWS plan and starts an unrelated list.

The reviewed diff instead classifies work:

**Retained:** Linux, networking, Python, Git, containers, Kubernetes workload state, CI, observability, incident reasoning, security and documentation.

**Adjacent but unproved:** provider IAM maps conceptually to identity and policy, but does not prove OpenStack Keystone or data-center access control. Managed storage concepts help comparison but do not prove Ceph operation.

**Deferred:** provider-specific serverless and managed database depth because they are no longer high-weight requirements.

**Added:** virtualization, image lifecycle, bridges/VLAN/VXLAN, bare-metal concepts, distributed storage placement/quorum/recovery and on-premises cluster upgrades.

**Invalidated assumption:** “managed control planes remove hardware responsibility” no longer describes the target.

**Unchanged proof limits:** local exercises still do not establish production fleet responsibility.

Capacity does not grow because the role changed. Suppose 39 of the 156 focus hours were used:

```text
remaining focus hours = 156 - 39 = 117
new branch cannot exceed 117 without a new capacity decision
```

The new plan assigns 30 hours virtualization, 30 storage, 21 network-control depth, 18 cluster lifecycle and 18 independent integration review. These are estimates. Each receives a milestone and acceptance gate; hours do not prove completion.

### Worked example 2 — Kubernetes evidence ladder

Target requirement: “Strong experience operating Kubernetes.”

Do not mark a single checkbox. Build a ladder:

**Reading evidence:** explain API server, etcd, scheduler, controller, kubelet, networking and storage roles. Proof limit: vocabulary and model only.

**Guided evidence:** deploy a local workload and inspect desired versus observed state. Proof limit: known happy path.

**Independent bounded evidence:** reviewer creates a readiness, service-endpoint, DNS, policy, scheduling or PVC failure. Learner traces it without answer-key access, recovers and cleans up. Proof limit: local topology and selected faults.

**Lifecycle evidence:** perform a controlled version or workload migration, preserve compatibility, rollback and verify state. Proof limit: lab lifecycle.

**Representative evidence:** authorized operation of a real team environment, including incident, upgrade, tenancy or capacity responsibility. This cannot be created by changing lab wording.

**Longitudinal evidence:** repeated safe operation and improvements across time. This usually depends on organizational opportunity.

The roadmap can target the next rung. It must not collapse the ladder into “Kubernetes: 80%.”

### Worked example 3 — a milestone fails

Milestone: “Implement a progressive deployment with automated rollback.”

Declared acceptance:

- artifact identity is immutable;
- 10% canary receives representative traffic;
- user-operation error and latency guardrails are evaluated;
- abort prevents further promotion;
- rollback restores the prior artifact;
- state compatibility remains valid;
- reviewer changes one failure;
- cleanup returns the lab to the allowlisted baseline.

During review, the canary returns errors, but the pipeline promotes anyway because the alert query has a ten-minute delay and the stage waits only five minutes.

Do not mark “mostly complete.” Investigate:

1. Expected evidence was unavailable inside the decision window.
2. The automation interpreted absence as success.
3. Promotion authority lacked a freshness invariant.
4. Rollback happened only after the wider rollout increased impact.

Repair options include a faster leading signal, a longer observation window, smaller blast radius or explicit “insufficient evidence” stop. The learner updates the pipeline contract and adds a regression case where telemetry is stale.

The failed attempt is useful evidence of diagnosis and learning. It is not evidence that progressive delivery was already mastered.

### Worked example 4 — two target roles under one capacity

Role A requires AWS, EKS, Terraform, CI/CD, observability and incidents. Role B requires on-premises Kubernetes, KVM, Ceph, Jenkins, Python and data-center lifecycle.

Shared 24-week foundation:

- Linux/system evidence: 30 focus hours;
- networking/request paths: 24;
- automation/tests: 24;
- containers/delivery: 24;
- observability/incidents: 24;
- review and integration: 18.

Total focus:

```text
30 + 24 + 24 + 24 + 24 + 18 = 144 hours
```

At three focus hours per week:

```text
144 / 3 = 48 weeks
```

This reveals that the supposed “24-week” foundation is impossible at the current focus allocation. The roadmap must change one of scope, capacity or duration. It cannot change arithmetic.

A safe revision might select a 72-hour first foundation slice over 24 weeks, then branch. Or maintain 144 hours over 48 weeks. The learner decides from real constraints.

After the shared slice:

- Role A adds provider identity/networking, EKS operating model, Terraform provider/state, managed data and regional recovery.
- Role B adds virtualization, physical/network topology, Ceph state/recovery, image/bare-metal lifecycle and on-premises upgrades.

Both can use Kubernetes, but the evidence context differs. A managed control-plane investigation does not automatically prove etcd or hypervisor ownership.

### Worked example 5 — certification versus project

Assume a current certification requires an estimated 80 preparation hours and fee `F`. A production-shaped local project requires 100 hours and no provider spend, but the target job explicitly lists the certification as preferred.

Do not ask which is universally better. Compare:

| Criterion | Credential | Project |
|---|---|---|
| published domain coverage | strong and versioned | selected by project design |
| practical artifact | limited | strong |
| independent standardized assessment | yes, under exam rules | only if reviewer added |
| target screening signal | possibly explicit | depends on review |
| production ownership | no | no, if local |
| time | 80-hour estimate | 100-hour estimate |
| money | fee `F` plus materials | local resource cost |
| expiry/change | exam version and renewal | technology and artifact staleness |

One decision: complete foundation work, build a smaller 60-hour project tied to exam domains, then schedule the credential if the requirement remains current. Another valid decision: prioritize the project if the certification is irrelevant. Record the rationale and review date.

### Worked example 6 — junior-to-senior growth without a promotion promise

The starting evidence shows safe bounded tasks with guidance. The target role expects multi-service reliability decisions.

The roadmap should not say “promotion in six months.” It can define increasing exercises:

1. independently close one service failure;
2. design and validate a reversible service change;
3. coordinate a simulated dependency incident;
4. create a prevention mechanism consumed by two fictional teams;
5. defend trade-offs under a changed capacity or security constraint;
6. obtain reviewer observations and delayed transfer.

Real senior responsibility also needs organizational context and opportunity. The local plan develops mechanisms and communication, while the gap ledger preserves adoption, authority and longitudinal production outcomes as missing.

### Worked example 7 — architecture is not an escape from coding

A learner wants to become an architect and proposes skipping implementation.

The roadmap selects a small architecture slice and requires:

- executable service and infrastructure definitions;
- tests for interface and failure assumptions;
- telemetry proving request flow;
- capacity arithmetic with units;
- threat model;
- migration and rollback;
- incident recovery;
- ADR with rejected alternatives;
- reviewer constraint change.

Implementation feedback may invalidate the design. The architect hypothesis becomes stronger when the learner updates the decision rather than defending an elegant diagram.

### Worked example 8 — a truthful quarterly review

A quarterly review records:

```text
planned milestones: 6
accepted: 3
failed awaiting repair: 1
stopped after role change: 1
not started due reserve use: 1
```

Completion percentage could be `3 / 6 × 100 = 50%`, but this number hides valid stopped work and learning. Report states individually:

- three accepted receipts and proof limits;
- one technical gap exposed by failure;
- one intentional priority decision;
- one capacity variance;
- no inferred level.

The next plan uses observed throughput of three accepted milestones, not the original optimism of six. Reliability planning learns from reality.

### Reviewer questions for every worked roadmap

- Which source version created this requirement?
- What work operation sits behind the tool name?
- What evidence is learner-owned and permitted?
- Which gap is critical rather than merely visible?
- Why does this prerequisite come first?
- Where is reserve and what was stopped?
- What failure makes the milestone meaningful?
- Who controls the independent change?
- What does the receipt not prove?
- Which event triggers a roadmap revision?

### Advanced roadmap-defense questions

#### Why does your roadmap begin with Linux and networking when the target says Kubernetes?

**Strong answer:** Kubernetes exposes declarative APIs, but workload failures still materialize as process, filesystem, resource, name-resolution, routing, socket and storage state. The foundation is not a detour; it reduces blind product-level guessing. I can preview Kubernetes while requiring independent Linux/request-path evidence before broad operational claims.

**Weak warning:** “Everyone says Linux first.” That supplies tradition, not a dependency rationale.

**Follow-up:** “What evidence lets someone skip part of the foundation?” A reviewer-controlled task that exercises the underlying mechanism, with explanation and proof limits—not self-confidence.

#### How do you decide between SRE and platform engineering?

**Strong answer:** Compare the actual role operations. SRE may weight service reliability, SLOs, incidents, capacity and toil. Platform work may weight reusable capabilities, developer journeys, interfaces, tenancy, policy and adoption. Both share software, systems and reliability. I would use two current role maps and learner-owned evidence, not an identity quiz.

**Weak warning:** “SRE monitors; platform engineers build Kubernetes.” Both reductions erase substantial work.

#### When should you learn multiple clouds?

**Strong answer:** First learn portable mechanisms and one target provider deeply enough to understand identity, networking, state, observability and failure. Add a second provider when a current role or architecture comparison requires it. Compare semantics instead of memorizing renamed services.

**Follow-up:** “What if the job descriptions mention AWS or GCP?” Preserve that disjunction in the source. Choose the provider supported by available evidence and state the other as adjacent or missing.

#### How can a local-first roadmap prepare for cloud work?

**Strong answer:** It can build software, IaC, identity reasoning, request paths, delivery, observability, incidents, state and architecture locally. Provider-specific API behavior, quotas, billing, managed-service failure and production authority remain unverified until an authorized environment exists. Local-first reduces cost; it does not erase that boundary.

#### Why not maximize interview study immediately?

**Strong answer:** Interviews retrieve evidence and reasoning. Early interview practice is useful for vocabulary and identifying gaps, but generated stories cannot replace performed work. I connect every later answer to accepted milestones and practise question intent throughout.

**Weak warning:** “I will memorize 500 answers.” Quantity increases contradiction and consumes practice capacity.

#### What is your strategy when a critical gap requires job access?

**Strong answer:** Keep the gap visible. Build adjacent mechanisms locally, use public/open-source opportunities safely, seek supervised exposure and target roles whose required responsibility is honest. Never create unauthorized production work or inflate simulations.

#### How do you know a project is large enough?

**Strong answer:** Size is determined by the target mechanisms and acceptance, not repository lines. One evolving service can be sufficient if it exposes state, interfaces, delivery, telemetry, failures, security, capacity, recovery and decisions. Add complexity only when a requirement earns it.

#### How will you avoid tutorial copying?

**Strong answer:** Use a tutorial only for initial guided exposure. Close it, reconstruct the model, vary inputs, accept a hidden failure, explain why evidence changed the decision and perform delayed transfer. Preserve attribution for any borrowed structure or code according to its license.

#### What if your reviewer disagrees with the roadmap?

**Strong answer:** Ask which requirement, evidence, dependency, capacity assumption or acceptance criterion they challenge. Record the objection and supporting evidence. Revise when evidence warrants it; preserve the decision if trade-offs remain unresolved. Authority and risk determine escalation.

**Weak warning:** either obeying every opinion or dismissing feedback without inspecting it.

#### How do you measure progress without a readiness percentage?

**Strong answer:** Report accepted receipts, environments, independence, proof limits, gaps, capacity variance and transfer observations. For example: “three milestones accepted, one failed awaiting repair, one stopped after the role changed.” This is more actionable than a composite number.

#### What would make you remove a milestone?

**Strong answer:** The role no longer requires it, a prerequisite invalidates its timing, evidence already closes it, its cost exceeds expected value, the environment is unsafe, or a higher-risk gap displaces it. Record the stopped-work decision.

#### How does security change the learning order?

**Strong answer:** Security is not a final module. Identity, secrets, least privilege, input validation, dependency provenance and audit enter each milestone. Specialized threat modelling, supply-chain and runtime controls deepen after their foundations.

#### How do cost and reliability interact in your roadmap?

**Strong answer:** Every project states resource units and reliability guardrails. A cheaper design that loses recovery or user outcomes is not automatically better. FinOps learning follows workload, architecture and measurement foundations, then examines unit economics and safe optimization.

#### What would convince you that your architecture reasoning improved?

**Strong answer:** In an unfamiliar review I begin with user operations and constraints, identify state and trust owners, quantify relevant units, model failures and recovery, compare alternatives, expose uncertainty and revise when a constraint changes. A diagram count would not convince me.

#### How do you prevent becoming the only person who can operate the project?

**Strong answer:** Reproducible setup, tested automation, runbooks, diagrams, decision records, least-privilege access, peer review and reviewer-led recovery. Advanced capability should reduce key-person risk.

#### What is the roadmap’s final destination?

**Strong answer:** There is no permanent “all DevOps complete” state. The destination for a target cycle is a set of accepted, transferable capabilities and honest gaps for a versioned role. Systems and requirements continue to change, so maintenance and learning remain.

### Practical roadmap review exercise

Take this fictional plan:

```text
Goal: Staff SRE in six months
Hours: 6/week
Work: AWS certification (100h), Kubernetes course (80h),
      Terraform course (60h), Python course (60h),
      three portfolio projects (180h), 100 interviews (100h)
Total declared work: 580h
```

Capacity:

```text
six-month capacity at 26 weeks = 6 × 26 = 156 hours
with 20% reserve = 156 × 0.20 = 31.2 hours
usable maximum before fixed maintenance ≈ 124.8 hours
declared work exceeds total capacity by 580 - 156 = 424 hours
```

Diagnosis:

- the title is not a valid acceptance target;
- work exceeds even unreserved capacity by 424 hours;
- courses are not evidence-shaped milestones;
- prerequisites and target-role weights are missing;
- projects have no failure or review contract;
- interview count has no quality or evidence link;
- no fixed maintenance, accessibility or recovery cost exists.

Repair:

1. freeze one current SRE role and one adjacent role;
2. inventory existing evidence;
3. choose a 60-hour evolving-service milestone addressing the highest prerequisite gap;
4. allocate roughly 31 hours reserve and the remaining hours among maintenance, review and focus;
5. use one current credential only if its role value survives the capacity decision;
6. derive a small interview set from performed evidence;
7. review after one independent hidden fault;
8. retain staff-level organizational responsibility as unproved.

The repaired plan looks less dramatic. It is executable, reviewable and truthful.

## Independent transfer and rubric

Use `ASM-0246` after guided practice. A reviewer supplies two unfamiliar, materially different current role descriptions, changes a hidden constraint, scores observable evidence and returns later for delayed review. The learner never receives a model answer.

### Independent deliverables

Produce role-source records, normalized work maps, evidence/gap ledgers, a curriculum dependency subgraph, capacity budgets, shared and specialist paths, evidence-shaped milestones, certification decisions, portfolio/interview boundaries, a versioned constraint-change diff, reviewer receipts and delayed transfer.

### One-hundred-point rubric

| Dimension | Points | Full-credit observable anchor |
|---|---:|---|
| Role fidelity | 10 | Preserves both role versions, contexts, requirements and unknowns |
| Work and responsibility | 10 | Separates tasks, knowledge, skills, autonomy, scope, complexity and influence |
| Evidence integrity | 10 | Retains provenance, permission, environment, recency, confidence and gaps |
| Dependency reasoning | 10 | Every sequence edge or exception has a technical rationale |
| Milestone quality | 10 | Artifacts, faults, recovery, cleanup, explanation and acceptance are explicit |
| Capacity | 10 | Fixed work, focus, reserve and stopped work conserve |
| Specialist branching | 10 | Shared foundation and role differences both remain visible |
| Portfolio/interview truth | 10 | External claims match completed permitted evidence and proof limits |
| Revision under change | 10 | Hidden changes produce a versioned justified diff |
| Delayed transfer | 10 | Later unfamiliar defense succeeds without answer-key dependence |

Do not define a universal pass score. Report anchors, critical safety failures, strongest evidence, highest-risk gap and one next experiment. Never infer level or hiring probability.

### Remediation

If role fidelity fails, return to the source. If evidence fails, withdraw the claim. If dependency reasoning fails, explain mechanisms. If capacity fails, stop work. If milestones are shallow, add faults and review. If transfer fails, increase novelty and delay. If confidentiality fails, remove prohibited material and audit the flow before continuing.

## References and review

The schema-backed source lock is `support/references/REF-1082.json` through `REF-1099.json`.

SFIA sources ground responsibility and role-profile separation. NIST NICE and OPM sources ground task/knowledge/skill, competency and job-related assessment. CNCF sources ground platforms and organization-level maturity without turning it into an individual score. GitLab provides one transparent career-framework example. Microsoft and AWS provide vendor role/task scopes. Google SRE sources ground training, on-call and reliability breadth. DORA contributes delivery capability research.

Public pages and certification contracts change. Revalidate source version and URL at the review date. Do not treat illustrative profiles as universal requirements.

Before publication require technical, security/privacy, accessibility, legal/policy, career-development, instructional and assessment review; full content/schema/reader/lint/type/build checks; Ubuntu lab rerun; learner-owned independent evidence; and delayed unfamiliar transfer. The chapter remains quarantined until those gates pass.

### Final operating wisdom

Build the plan around work, not identity. Build evidence around failures and recovery, not consumption. Build depth on prerequisites, not fashion. Protect finite capacity. Preserve every proof limit. Let titles, opportunities and employer decisions remain where their authority belongs.

When the roadmap feels slow, inspect the receipts before changing it. A small accepted capability that you can explain, break, recover and transfer is durable progress. Ten half-finished technologies are an inventory of open work. When the roadmap feels easy, add an unfamiliar constraint rather than a fashionable product. When it feels impossible, reduce simultaneous scope rather than removing evidence and safety. When a role changes, preserve the common mechanisms and make the branch explicit. When an opportunity is unavailable, keep the gap honest and strengthen adjacent evidence without borrowing authority.

The book can give you a dependency map, safe laboratories, questions, examples and review contracts. You still provide the practice, reflection and truthful evidence; reviewers provide independent observations; organizations provide real authority and opportunity. Keeping those owners separate is not a limitation of the roadmap. It is what makes the roadmap trustworthy.
