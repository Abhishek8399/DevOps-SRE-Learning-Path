# LES-0081 guarded FinOps evidence and calculation lab

This lab teaches cost reasoning from a fictional twelve-line billing ledger. It does not query AWS, Azure, Google Cloud, Kubernetes, a billing API, an invoice, a price catalog or a production system. Every provider, account, resource and price in the fixture is synthetic.

Run it as a normal Ubuntu 24.04 user from this directory:

```bash
bash lab.sh doctor
bash lab.sh setup
bash lab.sh status
bash lab.sh analyze
bash lab.sh allocate
bash lab.sh forecast
bash lab.sh commitment
bash lab.sh evaluate billed-effective-list-or-contracted-cost-confused
bash lab.sh evaluate optimization-ignores-slo-or-performance
bash lab.sh evaluate commitment-utilization-or-vacancy-unacceptable
bash verify.sh
```

`analyze` calculates list, contracted, billed and effective totals; direct allocation coverage; shared cost; unit costs; forecast variance; budget headroom; and period change. `allocate` applies a declared 60/40 shared-cost driver and proves source-to-target cost conservation. `forecast` keeps a point estimate separate from its uncertainty interval and budget. `commitment` exposes coverage, utilization and vacancy without recommending a purchase.

The verifier covers one defensible synthetic baseline and one isolated failure for each of 63 ordered gates. It also proves four calculation paths, exported cloud-authority refusal, root refusal, unknown-artifact refusal and exact UID-scoped cleanup.

The guard refuses common AWS, Azure, Google Cloud, Kubernetes, Docker, Terraform billing and cost-API authority variables. Do not bypass it. A real billing export can contain account names, resource identifiers, pricing, contracts, customer dimensions and organizational metadata; never copy it into this repository.

A representative exercise belongs only in a reviewer-owned sanitized dataset or isolated non-production billing sandbox. The reviewer must control access, query cost, retention, redaction, pricing assumptions, approval for any optimization, SLO stop conditions and cleanup. A synthetic saving is not realized saving, and a provider recommendation is not authorization.
