# LES-0086 guarded interview-evidence lab

This lab teaches evidence boundaries with fictional JSON. It does not assess a person, predict hiring, read a resume, record an interview, contact a company, send a message, invoke an AI service or use production systems.

## Requirements

- Ubuntu 24.04
- normal non-root user
- Bash and Python 3
- no cloud, Kubernetes, Docker, ATS, HR, resume, recording, live-interview, AI-service or production authority in the shell

## Run

```bash
bash lab.sh doctor
bash lab.sh setup
bash lab.sh status
bash lab.sh roadmap
bash lab.sh stories
bash lab.sh claims
bash lab.sh variants
bash lab.sh coverage
bash lab.sh followups
bash lab.sh evaluate fabricated-career-metric
bash lab.sh cleanup
```

Or run the complete guarded lifecycle:

```bash
bash verify.sh
```

Expected final line:

```text
verify=pass cases=73 calculations=5 refusal=true cleanup=true candidate_evaluation=none hiring_prediction=none external_calls=none
```

The percentages prove only fixture arithmetic. They do not prove a story is true, a learner is ready, an interview will follow a public guide, an interviewer will score a response a certain way, or a hiring outcome.
