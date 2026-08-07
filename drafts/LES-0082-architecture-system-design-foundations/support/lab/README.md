# LES-0082 guarded architecture and system-design lab

This lab turns a fictional checkout-design packet into explicit architecture evidence. It has no network access and calls no cloud, container, Kubernetes, infrastructure, database or production runtime. Its numbers are teaching inputs, not benchmark or sizing results.

Run as a normal Ubuntu 24.04 user from this directory:

```bash
bash lab.sh doctor
bash lab.sh setup
bash lab.sh status
bash lab.sh map
bash lab.sh capacity
bash lab.sh availability
bash lab.sh backlog
bash lab.sh latency
bash lab.sh tradeoff
bash lab.sh evaluate requirements-ambiguous-or-unmeasurable
bash lab.sh evaluate state-owner-or-writer-authority-unbound
bash lab.sh evaluate credible-alternatives-not-compared
bash verify.sh
```

The model has one defensible synthetic baseline plus one isolated failure for each of 66 ordered review gates. Its five calculations cover failure-aware capacity, serial availability, queue backlog and recovery, RPO exposure, latency-budget closure and weighted alternatives; backlog/RPO are emitted together as one calculation path.

The weighted score is a discussion aid, not an automatic decision. A high score can hide a veto constraint, bad assumption or sensitive tradeoff. Human owners must inspect the inputs, sensitivity and consequences.

The guard refuses root, common cloud credentials, Kubernetes or Docker authority and production endpoint variables. It creates one UID-scoped temporary directory, accepts only its sentinel and two copied fixtures, refuses unknown artifacts and proves exact cleanup. Do not weaken the guard.

For independent practice, a reviewer supplies an unfamiliar sanitized design brief with hidden constraint changes and scores the reasoning. Do not use employer diagrams, endpoints, customer data, credentials or confidential capacity/cost information in this repository.
